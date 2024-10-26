#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>

// 计算左子节点、右子节点和父节点的宏定义
#define LEFT_CHILD(index)   ((index) << 1)         // 左子节点索引
#define RIGHT_CHILD(index)  (((index) << 1) + 1)   // 右子节点索引
#define PARENT(index)       ((index) >> 1)         // 父节点索引
#define MAX(a, b)           ((a) > (b) ? (a) : (b)) // 计算最大值
#define BUDDY_MAX_DEPTH 30 // 伙伴系统的最大深度

// 全局变量声明
static unsigned int* buddy_page; // 用于存储每个大小的页数
static unsigned int buddy_page_num; // 伙伴页的数量
static unsigned int useable_page_num; // 可用的页数量
static struct Page* useable_page_base; // 可用页的基地址

// 初始化伙伴内存管理系统
static void
buddy_init(void) {}

// 初始化内存映射
static void
buddy_init_memmap(struct Page *base, size_t n) {
    // 检查参数，确保可用页数大于0
    assert((n > 0));

    // 计算可用内存页数
    useable_page_num = 1; // 从1开始计算可用页数
    for (int i = 1;
         (i < BUDDY_MAX_DEPTH) && (useable_page_num + (useable_page_num >> 9) < n);
         i++, useable_page_num <<= 1); // 逐步增加可用页数，直到达到最大深度或超出n

    useable_page_num >>= 1; // 可用页数向下取整
    buddy_page_num = (useable_page_num >> 9) + 1; // 计算管理页的数量

    // 确定可用内存页的基地址
    useable_page_base = base + buddy_page_num;

    // 初始化所有页的权限
    for (int i = 0; i != buddy_page_num; i++){
        SetPageReserved(base + i); // 标记为保留页
    }
    for (int i = buddy_page_num; i != n; i++){
        ClearPageReserved(base + i); // 清除保留标记
        SetPageProperty(base + i); // 设置页属性
        set_page_ref(base + i, 0); // 设置引用计数为0
    }
    
     // 初始化管理页
    buddy_page = (unsigned int*)KADDR(page2pa(base)); // 获取管理页地址
    for (int i = useable_page_num; i < useable_page_num << 1; i++){
        buddy_page[i] = 1; // 初始化页数为1
    }
    for (int i = useable_page_num - 1; i > 0; i--){
        buddy_page[i] = buddy_page[i << 1] << 1; // 更新父节点的页数
    }
}


// 分配指定数量的页
static struct Page* buddy_alloc_pages(size_t n) {
    // 检查参数
    assert(n > 0);
    // 如果请求的页数大于可用页数，则返回NULL（分配失败）
    if (n > buddy_page[1]){
        return NULL;
    }

    // 查找需要的页区
    unsigned int index = 1; // 从根节点开始查找
    while(1){
        if (buddy_page[LEFT_CHILD(index)] >= n){ // 如果左子节点的页数足够
            index = LEFT_CHILD(index); // 移动到左子节点
        }
        else if (buddy_page[RIGHT_CHILD(index)] >= n){ // 如果右子节点的页数足够
            index = RIGHT_CHILD(index); // 移动到右子节点
        }
        else{
            break; // 找到合适的节点，退出循环
        }
    }

    // 分配页面
    unsigned int size = buddy_page[index]; // 获取找到的页面大小
    buddy_page[index] = 0; // 清零计数，表示该节点及其子节点不可用
    struct Page* new_page = &useable_page_base[index * size - useable_page_num]; // 计算分配的页地址
    for (struct Page* p = new_page; p != new_page + size; p++){
        ClearPageProperty(p); // 清除页属性
        set_page_ref(p, 0); // 设置引用计数为0
    }

    // 更新上方节点
    index = PARENT(index);
    while(index > 0){
        buddy_page[index] = MAX(buddy_page[LEFT_CHILD(index)], buddy_page[RIGHT_CHILD(index)]); // 更新父节点的页数
        index = PARENT(index); // 向上移动到父节点
    }

    // 返回分配到的页
    return new_page;
}

// 释放指定的页
static void buddy_free_pages(struct Page *base, size_t n) {
    // 检查参数
    assert(n > 0);
    // 释放页面
    for (struct Page *p = base; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面未被保留且未设置属性
        SetPageProperty(p); // 设置页属性
        set_page_ref(p, 0); // 设置引用计数为0
    }

    // 维护管理页
    unsigned int index = useable_page_num + (unsigned int)(base - useable_page_base), size = 1; // 计算当前页面在管理页中的索引
    while(buddy_page[index] > 0){ // 找到第一个未分配的节点
        index=PARENT(index); // 向上移动到父节点
        size <<= 1; // 增加页数
    }
    buddy_page[index] = size; // 更新该节点的页数
    while((index = PARENT(index)) > 0){ // 更新所有父节点
        size <<= 1; // 增加页数
        if(buddy_page[LEFT_CHILD(index)] + buddy_page[RIGHT_CHILD(index)] == size){ // 如果子节点的页数等于当前节点页数
            buddy_page[index] = size; // 设置当前节点的页数
        }
        else{
            buddy_page[index] = MAX(buddy_page[LEFT_CHILD(index)], buddy_page[RIGHT_CHILD(index)]); // 否则取最大值
        }
    }
}

// 返回当前可用页的数量
static size_t buddy_nr_free_pages(void) {
    return buddy_page[1]; // 返回根节点的页数
}

// 检查伙伴内存管理系统的状态
static void buddy_check(void) {
    int all_pages = nr_free_pages(); // 获取所有页面数量
    struct Page* p0, *p1, *p2, *p3;

    // 尝试分配过大的页数，应该返回NULL
    assert(alloc_pages(all_pages + 1) == NULL);
    // 分配两个组页
    p0 = alloc_pages(1);
    assert(p0 != NULL); // 确保分配成功
    p1 = alloc_pages(2);
    assert(p1 == p0 + 2); // 确保分配的页地址连续
    assert(!PageReserved(p0) && !PageProperty(p0)); // 确保页面属性正确
    assert(!PageReserved(p1) && !PageProperty(p1));

    // 再分配两个组页
    p2 = alloc_pages(1);
    assert(p2 == p0 + 1); // 确保分配的页地址正确
    p3 = alloc_pages(8);
    assert(p3 == p0 + 8); // 确保分配的页地址连续
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));

    // 回收页
    free_pages(p1, 2);
    assert(PageProperty(p1) && PageProperty(p1 + 1)); // 确保页面属性已设置
    assert(p1->ref == 0); // 确保引用计数为0
    free_pages(p0, 1); // 释放p0页
    free_pages(p2, 1); // 释放p2页

    // 回收后再分配
    p2 = alloc_pages(3); // 分配3个页
    assert(p2 == p0); // 确保分配地址正确
    free_pages(p2, 3); // 释放3个页
    assert((p2 + 2)->ref == 0); // 确保引用计数为0
    assert(nr_free_pages() == all_pages >> 1); // 确保可用页数正确

    // 分配更多页面
    p1 = alloc_pages(129);
    assert(p1 == NULL); // 确保无法分配过多页
    assert(nr_free_pages() == all_pages >> 1); // 可用页数保持不变
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager", // 伙伴内存管理器的名称
    .init = buddy_init,           // 初始化函数，负责初始化伙伴内存管理系统
    .init_memmap = buddy_init_memmap, // 初始化内存映射函数，设置可用内存页面的信息
    .alloc_pages = buddy_alloc_pages, // 页面分配函数，分配指定数量的内存页
    .free_pages = buddy_free_pages,   // 页面释放函数，释放之前分配的内存页
    .nr_free_pages = buddy_nr_free_pages, // 返回当前可用内存页的数量
    .check = buddy_check,             // 状态检查函数，用于验证伙伴内存管理系统的正确性
};

