
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <buf>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43e60613          	addi	a2,a2,1086 # ffffffffc0206478 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	628010ef          	jal	ra,ffffffffc0201672 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	63650513          	addi	a0,a0,1590 # ffffffffc0201688 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	737000ef          	jal	ra,ffffffffc0200f9c <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	0f6010ef          	jal	ra,ffffffffc020119c <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	0c0010ef          	jal	ra,ffffffffc020119c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	56c50513          	addi	a0,a0,1388 # ffffffffc02016a8 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	57650513          	addi	a0,a0,1398 # ffffffffc02016c8 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	52658593          	addi	a1,a1,1318 # ffffffffc0201684 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	58250513          	addi	a0,a0,1410 # ffffffffc02016e8 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buf>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	58e50513          	addi	a0,a0,1422 # ffffffffc0201708 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2f258593          	addi	a1,a1,754 # ffffffffc0206478 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	59a50513          	addi	a0,a0,1434 # ffffffffc0201728 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6dd58593          	addi	a1,a1,1757 # ffffffffc0206877 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	58c50513          	addi	a0,a0,1420 # ffffffffc0201748 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	5ae60613          	addi	a2,a2,1454 # ffffffffc0201778 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	5ba50513          	addi	a0,a0,1466 # ffffffffc0201790 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	5c260613          	addi	a2,a2,1474 # ffffffffc02017a8 <etext+0x124>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	5da58593          	addi	a1,a1,1498 # ffffffffc02017c8 <etext+0x144>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	5da50513          	addi	a0,a0,1498 # ffffffffc02017d0 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	5dc60613          	addi	a2,a2,1500 # ffffffffc02017e0 <etext+0x15c>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	5fc58593          	addi	a1,a1,1532 # ffffffffc0201808 <etext+0x184>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	5bc50513          	addi	a0,a0,1468 # ffffffffc02017d0 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	5f860613          	addi	a2,a2,1528 # ffffffffc0201818 <etext+0x194>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	61058593          	addi	a1,a1,1552 # ffffffffc0201838 <etext+0x1b4>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	5a050513          	addi	a0,a0,1440 # ffffffffc02017d0 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	5de50513          	addi	a0,a0,1502 # ffffffffc0201848 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	5e450513          	addi	a0,a0,1508 # ffffffffc0201870 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	63ec0c13          	addi	s8,s8,1598 # ffffffffc02018e0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	5ee90913          	addi	s2,s2,1518 # ffffffffc0201898 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	5ee48493          	addi	s1,s1,1518 # ffffffffc02018a0 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	5ecb0b13          	addi	s6,s6,1516 # ffffffffc02018a8 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	504a0a13          	addi	s4,s4,1284 # ffffffffc02017c8 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	24e010ef          	jal	ra,ffffffffc020151e <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	5fad0d13          	addi	s10,s10,1530 # ffffffffc02018e0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	34a010ef          	jal	ra,ffffffffc020163e <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	336010ef          	jal	ra,ffffffffc020163e <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	316010ef          	jal	ra,ffffffffc020165c <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	2d8010ef          	jal	ra,ffffffffc020165c <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	52a50513          	addi	a0,a0,1322 # ffffffffc02018c8 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	54e50513          	addi	a0,a0,1358 # ffffffffc0201928 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	38050513          	addi	a0,a0,896 # ffffffffc0201770 <etext+0xec>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	1cc010ef          	jal	ra,ffffffffc02015ec <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	fe07b923          	sd	zero,-14(a5) # ffffffffc0206418 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	51a50513          	addi	a0,a0,1306 # ffffffffc0201948 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	1a60106f          	j	ffffffffc02015ec <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	1820106f          	j	ffffffffc02015d2 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	1b20106f          	j	ffffffffc0201606 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201968 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	4f250513          	addi	a0,a0,1266 # ffffffffc0201980 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	4fc50513          	addi	a0,a0,1276 # ffffffffc0201998 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	50650513          	addi	a0,a0,1286 # ffffffffc02019b0 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	51050513          	addi	a0,a0,1296 # ffffffffc02019c8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	51a50513          	addi	a0,a0,1306 # ffffffffc02019e0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	52450513          	addi	a0,a0,1316 # ffffffffc02019f8 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	52e50513          	addi	a0,a0,1326 # ffffffffc0201a10 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	53850513          	addi	a0,a0,1336 # ffffffffc0201a28 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	54250513          	addi	a0,a0,1346 # ffffffffc0201a40 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	54c50513          	addi	a0,a0,1356 # ffffffffc0201a58 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	55650513          	addi	a0,a0,1366 # ffffffffc0201a70 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	56050513          	addi	a0,a0,1376 # ffffffffc0201a88 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	56a50513          	addi	a0,a0,1386 # ffffffffc0201aa0 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	57450513          	addi	a0,a0,1396 # ffffffffc0201ab8 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	57e50513          	addi	a0,a0,1406 # ffffffffc0201ad0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	58850513          	addi	a0,a0,1416 # ffffffffc0201ae8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	59250513          	addi	a0,a0,1426 # ffffffffc0201b00 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	59c50513          	addi	a0,a0,1436 # ffffffffc0201b18 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	5a650513          	addi	a0,a0,1446 # ffffffffc0201b30 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	5b050513          	addi	a0,a0,1456 # ffffffffc0201b48 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	5ba50513          	addi	a0,a0,1466 # ffffffffc0201b60 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	5c450513          	addi	a0,a0,1476 # ffffffffc0201b78 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	5ce50513          	addi	a0,a0,1486 # ffffffffc0201b90 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	5d850513          	addi	a0,a0,1496 # ffffffffc0201ba8 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	5e250513          	addi	a0,a0,1506 # ffffffffc0201bc0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	5ec50513          	addi	a0,a0,1516 # ffffffffc0201bd8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	5f650513          	addi	a0,a0,1526 # ffffffffc0201bf0 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	60050513          	addi	a0,a0,1536 # ffffffffc0201c08 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	60a50513          	addi	a0,a0,1546 # ffffffffc0201c20 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	61450513          	addi	a0,a0,1556 # ffffffffc0201c38 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	61a50513          	addi	a0,a0,1562 # ffffffffc0201c50 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	61e50513          	addi	a0,a0,1566 # ffffffffc0201c68 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	61e50513          	addi	a0,a0,1566 # ffffffffc0201c80 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	62650513          	addi	a0,a0,1574 # ffffffffc0201c98 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	62e50513          	addi	a0,a0,1582 # ffffffffc0201cb0 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	63250513          	addi	a0,a0,1586 # ffffffffc0201cc8 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	6f870713          	addi	a4,a4,1784 # ffffffffc0201da8 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	67e50513          	addi	a0,a0,1662 # ffffffffc0201d40 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	65450513          	addi	a0,a0,1620 # ffffffffc0201d20 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	60a50513          	addi	a0,a0,1546 # ffffffffc0201ce0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	68050513          	addi	a0,a0,1664 # ffffffffc0201d60 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d2668693          	addi	a3,a3,-730 # ffffffffc0206418 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	67850513          	addi	a0,a0,1656 # ffffffffc0201d88 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	5e650513          	addi	a0,a0,1510 # ffffffffc0201d00 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	64c50513          	addi	a0,a0,1612 # ffffffffc0201d78 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_init>:
static unsigned int useable_page_num; // 可用的页数量
static struct Page* useable_page_base; // 可用页的基地址

// 初始化伙伴内存管理系统
static void
buddy_init(void) {}
ffffffffc0200802:	8082                	ret

ffffffffc0200804 <buddy_nr_free_pages>:
    }
}

// 返回当前可用页的数量
static size_t buddy_nr_free_pages(void) {
    return buddy_page[1]; // 返回根节点的页数
ffffffffc0200804:	00006797          	auipc	a5,0x6
ffffffffc0200808:	c1c7b783          	ld	a5,-996(a5) # ffffffffc0206420 <buddy_page>
}
ffffffffc020080c:	0047e503          	lwu	a0,4(a5)
ffffffffc0200810:	8082                	ret

ffffffffc0200812 <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc0200812:	c965                	beqz	a0,ffffffffc0200902 <buddy_alloc_pages+0xf0>
    if (n > buddy_page[1]){
ffffffffc0200814:	00006817          	auipc	a6,0x6
ffffffffc0200818:	c0c80813          	addi	a6,a6,-1012 # ffffffffc0206420 <buddy_page>
ffffffffc020081c:	00083583          	ld	a1,0(a6)
ffffffffc0200820:	0045e783          	lwu	a5,4(a1)
ffffffffc0200824:	0ca7ed63          	bltu	a5,a0,ffffffffc02008fe <buddy_alloc_pages+0xec>
    unsigned int index = 1; // 从根节点开始查找
ffffffffc0200828:	4705                	li	a4,1
        if (buddy_page[LEFT_CHILD(index)] >= n){ // 如果左子节点的页数足够
ffffffffc020082a:	0017169b          	slliw	a3,a4,0x1
ffffffffc020082e:	02069793          	slli	a5,a3,0x20
ffffffffc0200832:	83f9                	srli	a5,a5,0x1e
ffffffffc0200834:	97ae                	add	a5,a5,a1
ffffffffc0200836:	0007e783          	lwu	a5,0(a5)
ffffffffc020083a:	0007061b          	sext.w	a2,a4
ffffffffc020083e:	0006871b          	sext.w	a4,a3
ffffffffc0200842:	fea7f4e3          	bgeu	a5,a0,ffffffffc020082a <buddy_alloc_pages+0x18>
        else if (buddy_page[RIGHT_CHILD(index)] >= n){ // 如果右子节点的页数足够
ffffffffc0200846:	2705                	addiw	a4,a4,1
ffffffffc0200848:	02071693          	slli	a3,a4,0x20
ffffffffc020084c:	01e6d793          	srli	a5,a3,0x1e
ffffffffc0200850:	97ae                	add	a5,a5,a1
ffffffffc0200852:	0007e783          	lwu	a5,0(a5)
ffffffffc0200856:	fca7fae3          	bgeu	a5,a0,ffffffffc020082a <buddy_alloc_pages+0x18>
    unsigned int size = buddy_page[index]; // 获取找到的页面大小
ffffffffc020085a:	02061713          	slli	a4,a2,0x20
ffffffffc020085e:	01e75793          	srli	a5,a4,0x1e
ffffffffc0200862:	95be                	add	a1,a1,a5
ffffffffc0200864:	4198                	lw	a4,0(a1)
    struct Page* new_page = &useable_page_base[index * size - useable_page_num]; // 计算分配的页地址
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	bca53503          	ld	a0,-1078(a0) # ffffffffc0206430 <useable_page_base>
    buddy_page[index] = 0; // 清零计数，表示该节点及其子节点不可用
ffffffffc020086e:	0005a023          	sw	zero,0(a1)
    struct Page* new_page = &useable_page_base[index * size - useable_page_num]; // 计算分配的页地址
ffffffffc0200872:	02e607bb          	mulw	a5,a2,a4
    for (struct Page* p = new_page; p != new_page + size; p++){
ffffffffc0200876:	02071693          	slli	a3,a4,0x20
ffffffffc020087a:	9281                	srli	a3,a3,0x20
ffffffffc020087c:	00269713          	slli	a4,a3,0x2
ffffffffc0200880:	9736                	add	a4,a4,a3
    struct Page* new_page = &useable_page_base[index * size - useable_page_num]; // 计算分配的页地址
ffffffffc0200882:	00006697          	auipc	a3,0x6
ffffffffc0200886:	bb66a683          	lw	a3,-1098(a3) # ffffffffc0206438 <useable_page_num>
    for (struct Page* p = new_page; p != new_page + size; p++){
ffffffffc020088a:	070e                	slli	a4,a4,0x3
    struct Page* new_page = &useable_page_base[index * size - useable_page_num]; // 计算分配的页地址
ffffffffc020088c:	9f95                	subw	a5,a5,a3
ffffffffc020088e:	1782                	slli	a5,a5,0x20
ffffffffc0200890:	9381                	srli	a5,a5,0x20
ffffffffc0200892:	00279693          	slli	a3,a5,0x2
ffffffffc0200896:	97b6                	add	a5,a5,a3
ffffffffc0200898:	078e                	slli	a5,a5,0x3
ffffffffc020089a:	953e                	add	a0,a0,a5
    for (struct Page* p = new_page; p != new_page + size; p++){
ffffffffc020089c:	972a                	add	a4,a4,a0
ffffffffc020089e:	00e50e63          	beq	a0,a4,ffffffffc02008ba <buddy_alloc_pages+0xa8>
ffffffffc02008a2:	87aa                	mv	a5,a0
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008a4:	56f5                	li	a3,-3
ffffffffc02008a6:	00878593          	addi	a1,a5,8
ffffffffc02008aa:	60d5b02f          	amoand.d	zero,a3,(a1)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02008ae:	0007a023          	sw	zero,0(a5)
ffffffffc02008b2:	02878793          	addi	a5,a5,40
ffffffffc02008b6:	fee798e3          	bne	a5,a4,ffffffffc02008a6 <buddy_alloc_pages+0x94>
    index = PARENT(index);
ffffffffc02008ba:	0016561b          	srliw	a2,a2,0x1
    while(index > 0){
ffffffffc02008be:	c229                	beqz	a2,ffffffffc0200900 <buddy_alloc_pages+0xee>
        buddy_page[index] = MAX(buddy_page[LEFT_CHILD(index)], buddy_page[RIGHT_CHILD(index)]); // 更新父节点的页数
ffffffffc02008c0:	00083683          	ld	a3,0(a6)
ffffffffc02008c4:	0016179b          	slliw	a5,a2,0x1
ffffffffc02008c8:	0017871b          	addiw	a4,a5,1
ffffffffc02008cc:	1782                	slli	a5,a5,0x20
ffffffffc02008ce:	02071593          	slli	a1,a4,0x20
ffffffffc02008d2:	9381                	srli	a5,a5,0x20
ffffffffc02008d4:	01e5d713          	srli	a4,a1,0x1e
ffffffffc02008d8:	078a                	slli	a5,a5,0x2
ffffffffc02008da:	97b6                	add	a5,a5,a3
ffffffffc02008dc:	9736                	add	a4,a4,a3
ffffffffc02008de:	438c                	lw	a1,0(a5)
ffffffffc02008e0:	4318                	lw	a4,0(a4)
ffffffffc02008e2:	00261793          	slli	a5,a2,0x2
ffffffffc02008e6:	0005881b          	sext.w	a6,a1
ffffffffc02008ea:	0007089b          	sext.w	a7,a4
ffffffffc02008ee:	97b6                	add	a5,a5,a3
ffffffffc02008f0:	0108f363          	bgeu	a7,a6,ffffffffc02008f6 <buddy_alloc_pages+0xe4>
ffffffffc02008f4:	872e                	mv	a4,a1
ffffffffc02008f6:	c398                	sw	a4,0(a5)
        index = PARENT(index); // 向上移动到父节点
ffffffffc02008f8:	8205                	srli	a2,a2,0x1
    while(index > 0){
ffffffffc02008fa:	f669                	bnez	a2,ffffffffc02008c4 <buddy_alloc_pages+0xb2>
ffffffffc02008fc:	8082                	ret
        return NULL;
ffffffffc02008fe:	4501                	li	a0,0
}
ffffffffc0200900:	8082                	ret
static struct Page* buddy_alloc_pages(size_t n) {
ffffffffc0200902:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200904:	00001697          	auipc	a3,0x1
ffffffffc0200908:	4d468693          	addi	a3,a3,1236 # ffffffffc0201dd8 <commands+0x4f8>
ffffffffc020090c:	00001617          	auipc	a2,0x1
ffffffffc0200910:	4d460613          	addi	a2,a2,1236 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200914:	04100593          	li	a1,65
ffffffffc0200918:	00001517          	auipc	a0,0x1
ffffffffc020091c:	4e050513          	addi	a0,a0,1248 # ffffffffc0201df8 <commands+0x518>
static struct Page* buddy_alloc_pages(size_t n) {
ffffffffc0200920:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200922:	a8bff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200926 <buddy_check>:

// 检查伙伴内存管理系统的状态
static void buddy_check(void) {
ffffffffc0200926:	7179                	addi	sp,sp,-48
ffffffffc0200928:	e84a                	sd	s2,16(sp)
ffffffffc020092a:	f406                	sd	ra,40(sp)
ffffffffc020092c:	f022                	sd	s0,32(sp)
ffffffffc020092e:	ec26                	sd	s1,24(sp)
ffffffffc0200930:	e44e                	sd	s3,8(sp)
    int all_pages = nr_free_pages(); // 获取所有页面数量
ffffffffc0200932:	630000ef          	jal	ra,ffffffffc0200f62 <nr_free_pages>
ffffffffc0200936:	892a                	mv	s2,a0
    struct Page* p0, *p1, *p2, *p3;

    // 尝试分配过大的页数，应该返回NULL
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200938:	2505                	addiw	a0,a0,1
ffffffffc020093a:	5aa000ef          	jal	ra,ffffffffc0200ee4 <alloc_pages>
ffffffffc020093e:	24051863          	bnez	a0,ffffffffc0200b8e <buddy_check+0x268>
    // 分配两个组页
    p0 = alloc_pages(1);
ffffffffc0200942:	4505                	li	a0,1
ffffffffc0200944:	5a0000ef          	jal	ra,ffffffffc0200ee4 <alloc_pages>
ffffffffc0200948:	842a                	mv	s0,a0
    assert(p0 != NULL); // 确保分配成功
ffffffffc020094a:	22050263          	beqz	a0,ffffffffc0200b6e <buddy_check+0x248>
    p1 = alloc_pages(2);
ffffffffc020094e:	4509                	li	a0,2
ffffffffc0200950:	594000ef          	jal	ra,ffffffffc0200ee4 <alloc_pages>
    assert(p1 == p0 + 2); // 确保分配的页地址连续
ffffffffc0200954:	05040793          	addi	a5,s0,80
    p1 = alloc_pages(2);
ffffffffc0200958:	84aa                	mv	s1,a0
    assert(p1 == p0 + 2); // 确保分配的页地址连续
ffffffffc020095a:	1ef51a63          	bne	a0,a5,ffffffffc0200b4e <buddy_check+0x228>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020095e:	641c                	ld	a5,8(s0)
    assert(!PageReserved(p0) && !PageProperty(p0)); // 确保页面属性正确
ffffffffc0200960:	8b85                	andi	a5,a5,1
ffffffffc0200962:	10079663          	bnez	a5,ffffffffc0200a6e <buddy_check+0x148>
ffffffffc0200966:	641c                	ld	a5,8(s0)
ffffffffc0200968:	8385                	srli	a5,a5,0x1
ffffffffc020096a:	8b85                	andi	a5,a5,1
ffffffffc020096c:	10079163          	bnez	a5,ffffffffc0200a6e <buddy_check+0x148>
ffffffffc0200970:	651c                	ld	a5,8(a0)
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200972:	8b85                	andi	a5,a5,1
ffffffffc0200974:	0c079d63          	bnez	a5,ffffffffc0200a4e <buddy_check+0x128>
ffffffffc0200978:	651c                	ld	a5,8(a0)
ffffffffc020097a:	8385                	srli	a5,a5,0x1
ffffffffc020097c:	8b85                	andi	a5,a5,1
ffffffffc020097e:	ebe1                	bnez	a5,ffffffffc0200a4e <buddy_check+0x128>

    // 再分配两个组页
    p2 = alloc_pages(1);
ffffffffc0200980:	4505                	li	a0,1
ffffffffc0200982:	562000ef          	jal	ra,ffffffffc0200ee4 <alloc_pages>
    assert(p2 == p0 + 1); // 确保分配的页地址正确
ffffffffc0200986:	02840793          	addi	a5,s0,40
    p2 = alloc_pages(1);
ffffffffc020098a:	89aa                	mv	s3,a0
    assert(p2 == p0 + 1); // 确保分配的页地址正确
ffffffffc020098c:	1af51163          	bne	a0,a5,ffffffffc0200b2e <buddy_check+0x208>
    p3 = alloc_pages(8);
ffffffffc0200990:	4521                	li	a0,8
ffffffffc0200992:	552000ef          	jal	ra,ffffffffc0200ee4 <alloc_pages>
    assert(p3 == p0 + 8); // 确保分配的页地址连续
ffffffffc0200996:	14040793          	addi	a5,s0,320
ffffffffc020099a:	16f51a63          	bne	a0,a5,ffffffffc0200b0e <buddy_check+0x1e8>
ffffffffc020099e:	651c                	ld	a5,8(a0)
ffffffffc02009a0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc02009a2:	8b85                	andi	a5,a5,1
ffffffffc02009a4:	e7c9                	bnez	a5,ffffffffc0200a2e <buddy_check+0x108>
ffffffffc02009a6:	12053783          	ld	a5,288(a0)
ffffffffc02009aa:	8385                	srli	a5,a5,0x1
ffffffffc02009ac:	8b85                	andi	a5,a5,1
ffffffffc02009ae:	e3c1                	bnez	a5,ffffffffc0200a2e <buddy_check+0x108>
ffffffffc02009b0:	14853783          	ld	a5,328(a0)
ffffffffc02009b4:	8385                	srli	a5,a5,0x1
ffffffffc02009b6:	8b85                	andi	a5,a5,1
ffffffffc02009b8:	cbbd                	beqz	a5,ffffffffc0200a2e <buddy_check+0x108>

    // 回收页
    free_pages(p1, 2);
ffffffffc02009ba:	4589                	li	a1,2
ffffffffc02009bc:	8526                	mv	a0,s1
ffffffffc02009be:	564000ef          	jal	ra,ffffffffc0200f22 <free_pages>
ffffffffc02009c2:	649c                	ld	a5,8(s1)
ffffffffc02009c4:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && PageProperty(p1 + 1)); // 确保页面属性已设置
ffffffffc02009c6:	8b85                	andi	a5,a5,1
ffffffffc02009c8:	c3f9                	beqz	a5,ffffffffc0200a8e <buddy_check+0x168>
ffffffffc02009ca:	789c                	ld	a5,48(s1)
ffffffffc02009cc:	8385                	srli	a5,a5,0x1
ffffffffc02009ce:	8b85                	andi	a5,a5,1
ffffffffc02009d0:	cfdd                	beqz	a5,ffffffffc0200a8e <buddy_check+0x168>
    assert(p1->ref == 0); // 确保引用计数为0
ffffffffc02009d2:	409c                	lw	a5,0(s1)
ffffffffc02009d4:	0c079d63          	bnez	a5,ffffffffc0200aae <buddy_check+0x188>
    free_pages(p0, 1); // 释放p0页
ffffffffc02009d8:	4585                	li	a1,1
ffffffffc02009da:	8522                	mv	a0,s0
ffffffffc02009dc:	546000ef          	jal	ra,ffffffffc0200f22 <free_pages>
    free_pages(p2, 1); // 释放p2页
ffffffffc02009e0:	854e                	mv	a0,s3
ffffffffc02009e2:	4585                	li	a1,1
ffffffffc02009e4:	53e000ef          	jal	ra,ffffffffc0200f22 <free_pages>

    // 回收后再分配
    p2 = alloc_pages(3); // 分配3个页
ffffffffc02009e8:	450d                	li	a0,3
ffffffffc02009ea:	4fa000ef          	jal	ra,ffffffffc0200ee4 <alloc_pages>
    assert(p2 == p0); // 确保分配地址正确
ffffffffc02009ee:	10a41063          	bne	s0,a0,ffffffffc0200aee <buddy_check+0x1c8>
    free_pages(p2, 3); // 释放3个页
ffffffffc02009f2:	458d                	li	a1,3
ffffffffc02009f4:	52e000ef          	jal	ra,ffffffffc0200f22 <free_pages>
    assert((p2 + 2)->ref == 0); // 确保引用计数为0
ffffffffc02009f8:	483c                	lw	a5,80(s0)
ffffffffc02009fa:	ebf1                	bnez	a5,ffffffffc0200ace <buddy_check+0x1a8>
    assert(nr_free_pages() == all_pages >> 1); // 确保可用页数正确
ffffffffc02009fc:	2901                	sext.w	s2,s2
ffffffffc02009fe:	564000ef          	jal	ra,ffffffffc0200f62 <nr_free_pages>
ffffffffc0200a02:	40195913          	srai	s2,s2,0x1
ffffffffc0200a06:	842a                	mv	s0,a0
ffffffffc0200a08:	1f251363          	bne	a0,s2,ffffffffc0200bee <buddy_check+0x2c8>

    // 分配更多页面
    p1 = alloc_pages(129);
ffffffffc0200a0c:	08100513          	li	a0,129
ffffffffc0200a10:	4d4000ef          	jal	ra,ffffffffc0200ee4 <alloc_pages>
    assert(p1 == NULL); // 确保无法分配过多页
ffffffffc0200a14:	1a051d63          	bnez	a0,ffffffffc0200bce <buddy_check+0x2a8>
    assert(nr_free_pages() == all_pages >> 1); // 可用页数保持不变
ffffffffc0200a18:	54a000ef          	jal	ra,ffffffffc0200f62 <nr_free_pages>
ffffffffc0200a1c:	18a41963          	bne	s0,a0,ffffffffc0200bae <buddy_check+0x288>
}
ffffffffc0200a20:	70a2                	ld	ra,40(sp)
ffffffffc0200a22:	7402                	ld	s0,32(sp)
ffffffffc0200a24:	64e2                	ld	s1,24(sp)
ffffffffc0200a26:	6942                	ld	s2,16(sp)
ffffffffc0200a28:	69a2                	ld	s3,8(sp)
ffffffffc0200a2a:	6145                	addi	sp,sp,48
ffffffffc0200a2c:	8082                	ret
    assert(!PageProperty(p3) && !PageProperty(p3 + 7) && PageProperty(p3 + 8));
ffffffffc0200a2e:	00001697          	auipc	a3,0x1
ffffffffc0200a32:	49a68693          	addi	a3,a3,1178 # ffffffffc0201ec8 <commands+0x5e8>
ffffffffc0200a36:	00001617          	auipc	a2,0x1
ffffffffc0200a3a:	3aa60613          	addi	a2,a2,938 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200a3e:	09f00593          	li	a1,159
ffffffffc0200a42:	00001517          	auipc	a0,0x1
ffffffffc0200a46:	3b650513          	addi	a0,a0,950 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200a4a:	963ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageReserved(p1) && !PageProperty(p1));
ffffffffc0200a4e:	00001697          	auipc	a3,0x1
ffffffffc0200a52:	43268693          	addi	a3,a3,1074 # ffffffffc0201e80 <commands+0x5a0>
ffffffffc0200a56:	00001617          	auipc	a2,0x1
ffffffffc0200a5a:	38a60613          	addi	a2,a2,906 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200a5e:	09800593          	li	a1,152
ffffffffc0200a62:	00001517          	auipc	a0,0x1
ffffffffc0200a66:	39650513          	addi	a0,a0,918 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200a6a:	943ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageReserved(p0) && !PageProperty(p0)); // 确保页面属性正确
ffffffffc0200a6e:	00001697          	auipc	a3,0x1
ffffffffc0200a72:	3ea68693          	addi	a3,a3,1002 # ffffffffc0201e58 <commands+0x578>
ffffffffc0200a76:	00001617          	auipc	a2,0x1
ffffffffc0200a7a:	36a60613          	addi	a2,a2,874 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200a7e:	09700593          	li	a1,151
ffffffffc0200a82:	00001517          	auipc	a0,0x1
ffffffffc0200a86:	37650513          	addi	a0,a0,886 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200a8a:	923ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p1) && PageProperty(p1 + 1)); // 确保页面属性已设置
ffffffffc0200a8e:	00001697          	auipc	a3,0x1
ffffffffc0200a92:	48268693          	addi	a3,a3,1154 # ffffffffc0201f10 <commands+0x630>
ffffffffc0200a96:	00001617          	auipc	a2,0x1
ffffffffc0200a9a:	34a60613          	addi	a2,a2,842 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200a9e:	0a300593          	li	a1,163
ffffffffc0200aa2:	00001517          	auipc	a0,0x1
ffffffffc0200aa6:	35650513          	addi	a0,a0,854 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200aaa:	903ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1->ref == 0); // 确保引用计数为0
ffffffffc0200aae:	00001697          	auipc	a3,0x1
ffffffffc0200ab2:	49268693          	addi	a3,a3,1170 # ffffffffc0201f40 <commands+0x660>
ffffffffc0200ab6:	00001617          	auipc	a2,0x1
ffffffffc0200aba:	32a60613          	addi	a2,a2,810 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200abe:	0a400593          	li	a1,164
ffffffffc0200ac2:	00001517          	auipc	a0,0x1
ffffffffc0200ac6:	33650513          	addi	a0,a0,822 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200aca:	8e3ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 + 2)->ref == 0); // 确保引用计数为0
ffffffffc0200ace:	00001697          	auipc	a3,0x1
ffffffffc0200ad2:	49268693          	addi	a3,a3,1170 # ffffffffc0201f60 <commands+0x680>
ffffffffc0200ad6:	00001617          	auipc	a2,0x1
ffffffffc0200ada:	30a60613          	addi	a2,a2,778 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200ade:	0ac00593          	li	a1,172
ffffffffc0200ae2:	00001517          	auipc	a0,0x1
ffffffffc0200ae6:	31650513          	addi	a0,a0,790 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200aea:	8c3ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 == p0); // 确保分配地址正确
ffffffffc0200aee:	00001697          	auipc	a3,0x1
ffffffffc0200af2:	46268693          	addi	a3,a3,1122 # ffffffffc0201f50 <commands+0x670>
ffffffffc0200af6:	00001617          	auipc	a2,0x1
ffffffffc0200afa:	2ea60613          	addi	a2,a2,746 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200afe:	0aa00593          	li	a1,170
ffffffffc0200b02:	00001517          	auipc	a0,0x1
ffffffffc0200b06:	2f650513          	addi	a0,a0,758 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200b0a:	8a3ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p3 == p0 + 8); // 确保分配的页地址连续
ffffffffc0200b0e:	00001697          	auipc	a3,0x1
ffffffffc0200b12:	3aa68693          	addi	a3,a3,938 # ffffffffc0201eb8 <commands+0x5d8>
ffffffffc0200b16:	00001617          	auipc	a2,0x1
ffffffffc0200b1a:	2ca60613          	addi	a2,a2,714 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200b1e:	09e00593          	li	a1,158
ffffffffc0200b22:	00001517          	auipc	a0,0x1
ffffffffc0200b26:	2d650513          	addi	a0,a0,726 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200b2a:	883ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 == p0 + 1); // 确保分配的页地址正确
ffffffffc0200b2e:	00001697          	auipc	a3,0x1
ffffffffc0200b32:	37a68693          	addi	a3,a3,890 # ffffffffc0201ea8 <commands+0x5c8>
ffffffffc0200b36:	00001617          	auipc	a2,0x1
ffffffffc0200b3a:	2aa60613          	addi	a2,a2,682 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200b3e:	09c00593          	li	a1,156
ffffffffc0200b42:	00001517          	auipc	a0,0x1
ffffffffc0200b46:	2b650513          	addi	a0,a0,694 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200b4a:	863ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 == p0 + 2); // 确保分配的页地址连续
ffffffffc0200b4e:	00001697          	auipc	a3,0x1
ffffffffc0200b52:	2fa68693          	addi	a3,a3,762 # ffffffffc0201e48 <commands+0x568>
ffffffffc0200b56:	00001617          	auipc	a2,0x1
ffffffffc0200b5a:	28a60613          	addi	a2,a2,650 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200b5e:	09600593          	li	a1,150
ffffffffc0200b62:	00001517          	auipc	a0,0x1
ffffffffc0200b66:	29650513          	addi	a0,a0,662 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200b6a:	843ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL); // 确保分配成功
ffffffffc0200b6e:	00001697          	auipc	a3,0x1
ffffffffc0200b72:	2ca68693          	addi	a3,a3,714 # ffffffffc0201e38 <commands+0x558>
ffffffffc0200b76:	00001617          	auipc	a2,0x1
ffffffffc0200b7a:	26a60613          	addi	a2,a2,618 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200b7e:	09400593          	li	a1,148
ffffffffc0200b82:	00001517          	auipc	a0,0x1
ffffffffc0200b86:	27650513          	addi	a0,a0,630 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200b8a:	823ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(all_pages + 1) == NULL);
ffffffffc0200b8e:	00001697          	auipc	a3,0x1
ffffffffc0200b92:	28268693          	addi	a3,a3,642 # ffffffffc0201e10 <commands+0x530>
ffffffffc0200b96:	00001617          	auipc	a2,0x1
ffffffffc0200b9a:	24a60613          	addi	a2,a2,586 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200b9e:	09100593          	li	a1,145
ffffffffc0200ba2:	00001517          	auipc	a0,0x1
ffffffffc0200ba6:	25650513          	addi	a0,a0,598 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200baa:	803ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == all_pages >> 1); // 可用页数保持不变
ffffffffc0200bae:	00001697          	auipc	a3,0x1
ffffffffc0200bb2:	3ca68693          	addi	a3,a3,970 # ffffffffc0201f78 <commands+0x698>
ffffffffc0200bb6:	00001617          	auipc	a2,0x1
ffffffffc0200bba:	22a60613          	addi	a2,a2,554 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200bbe:	0b200593          	li	a1,178
ffffffffc0200bc2:	00001517          	auipc	a0,0x1
ffffffffc0200bc6:	23650513          	addi	a0,a0,566 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200bca:	fe2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p1 == NULL); // 确保无法分配过多页
ffffffffc0200bce:	00001697          	auipc	a3,0x1
ffffffffc0200bd2:	3d268693          	addi	a3,a3,978 # ffffffffc0201fa0 <commands+0x6c0>
ffffffffc0200bd6:	00001617          	auipc	a2,0x1
ffffffffc0200bda:	20a60613          	addi	a2,a2,522 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200bde:	0b100593          	li	a1,177
ffffffffc0200be2:	00001517          	auipc	a0,0x1
ffffffffc0200be6:	21650513          	addi	a0,a0,534 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200bea:	fc2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free_pages() == all_pages >> 1); // 确保可用页数正确
ffffffffc0200bee:	00001697          	auipc	a3,0x1
ffffffffc0200bf2:	38a68693          	addi	a3,a3,906 # ffffffffc0201f78 <commands+0x698>
ffffffffc0200bf6:	00001617          	auipc	a2,0x1
ffffffffc0200bfa:	1ea60613          	addi	a2,a2,490 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200bfe:	0ad00593          	li	a1,173
ffffffffc0200c02:	00001517          	auipc	a0,0x1
ffffffffc0200c06:	1f650513          	addi	a0,a0,502 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200c0a:	fa2ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c0e <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200c0e:	1141                	addi	sp,sp,-16
ffffffffc0200c10:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c12:	10058263          	beqz	a1,ffffffffc0200d16 <buddy_free_pages+0x108>
    for (struct Page *p = base; p != base + n; p++) {
ffffffffc0200c16:	00259693          	slli	a3,a1,0x2
ffffffffc0200c1a:	96ae                	add	a3,a3,a1
ffffffffc0200c1c:	068e                	slli	a3,a3,0x3
ffffffffc0200c1e:	96aa                	add	a3,a3,a0
ffffffffc0200c20:	87aa                	mv	a5,a0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c22:	4609                	li	a2,2
ffffffffc0200c24:	02d50263          	beq	a0,a3,ffffffffc0200c48 <buddy_free_pages+0x3a>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c28:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面未被保留且未设置属性
ffffffffc0200c2a:	8b05                	andi	a4,a4,1
ffffffffc0200c2c:	e769                	bnez	a4,ffffffffc0200cf6 <buddy_free_pages+0xe8>
ffffffffc0200c2e:	6798                	ld	a4,8(a5)
ffffffffc0200c30:	8b09                	andi	a4,a4,2
ffffffffc0200c32:	e371                	bnez	a4,ffffffffc0200cf6 <buddy_free_pages+0xe8>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c34:	00878713          	addi	a4,a5,8
ffffffffc0200c38:	40c7302f          	amoor.d	zero,a2,(a4)
ffffffffc0200c3c:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p != base + n; p++) {
ffffffffc0200c40:	02878793          	addi	a5,a5,40
ffffffffc0200c44:	fed792e3          	bne	a5,a3,ffffffffc0200c28 <buddy_free_pages+0x1a>
    unsigned int index = useable_page_num + (unsigned int)(base - useable_page_base), size = 1; // 计算当前页面在管理页中的索引
ffffffffc0200c48:	00005797          	auipc	a5,0x5
ffffffffc0200c4c:	7e87b783          	ld	a5,2024(a5) # ffffffffc0206430 <useable_page_base>
ffffffffc0200c50:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c54:	878d                	srai	a5,a5,0x3
ffffffffc0200c56:	00001697          	auipc	a3,0x1
ffffffffc0200c5a:	7726b683          	ld	a3,1906(a3) # ffffffffc02023c8 <error_string+0x38>
ffffffffc0200c5e:	02d786b3          	mul	a3,a5,a3
ffffffffc0200c62:	00005797          	auipc	a5,0x5
ffffffffc0200c66:	7d67a783          	lw	a5,2006(a5) # ffffffffc0206438 <useable_page_num>
    while(buddy_page[index] > 0){ // 找到第一个未分配的节点
ffffffffc0200c6a:	00005617          	auipc	a2,0x5
ffffffffc0200c6e:	7b663603          	ld	a2,1974(a2) # ffffffffc0206420 <buddy_page>
    unsigned int index = useable_page_num + (unsigned int)(base - useable_page_base), size = 1; // 计算当前页面在管理页中的索引
ffffffffc0200c72:	4705                	li	a4,1
ffffffffc0200c74:	9fb5                	addw	a5,a5,a3
    while(buddy_page[index] > 0){ // 找到第一个未分配的节点
ffffffffc0200c76:	02079593          	slli	a1,a5,0x20
ffffffffc0200c7a:	01e5d693          	srli	a3,a1,0x1e
ffffffffc0200c7e:	96b2                	add	a3,a3,a2
ffffffffc0200c80:	428c                	lw	a1,0(a3)
ffffffffc0200c82:	c999                	beqz	a1,ffffffffc0200c98 <buddy_free_pages+0x8a>
        index=PARENT(index); // 向上移动到父节点
ffffffffc0200c84:	0017d79b          	srliw	a5,a5,0x1
    while(buddy_page[index] > 0){ // 找到第一个未分配的节点
ffffffffc0200c88:	02079693          	slli	a3,a5,0x20
ffffffffc0200c8c:	82f9                	srli	a3,a3,0x1e
ffffffffc0200c8e:	96b2                	add	a3,a3,a2
ffffffffc0200c90:	428c                	lw	a1,0(a3)
        size <<= 1; // 增加页数
ffffffffc0200c92:	0017171b          	slliw	a4,a4,0x1
    while(buddy_page[index] > 0){ // 找到第一个未分配的节点
ffffffffc0200c96:	f5fd                	bnez	a1,ffffffffc0200c84 <buddy_free_pages+0x76>
    buddy_page[index] = size; // 更新该节点的页数
ffffffffc0200c98:	c298                	sw	a4,0(a3)
    while((index = PARENT(index)) > 0){ // 更新所有父节点
ffffffffc0200c9a:	0017d59b          	srliw	a1,a5,0x1
ffffffffc0200c9e:	e199                	bnez	a1,ffffffffc0200ca4 <buddy_free_pages+0x96>
ffffffffc0200ca0:	a881                	j	ffffffffc0200cf0 <buddy_free_pages+0xe2>
ffffffffc0200ca2:	85b6                	mv	a1,a3
        if(buddy_page[LEFT_CHILD(index)] + buddy_page[RIGHT_CHILD(index)] == size){ // 如果子节点的页数等于当前节点页数
ffffffffc0200ca4:	9bf9                	andi	a5,a5,-2
ffffffffc0200ca6:	02079693          	slli	a3,a5,0x20
ffffffffc0200caa:	2785                	addiw	a5,a5,1
ffffffffc0200cac:	02079513          	slli	a0,a5,0x20
ffffffffc0200cb0:	9281                	srli	a3,a3,0x20
ffffffffc0200cb2:	01e55793          	srli	a5,a0,0x1e
ffffffffc0200cb6:	068a                	slli	a3,a3,0x2
ffffffffc0200cb8:	97b2                	add	a5,a5,a2
ffffffffc0200cba:	96b2                	add	a3,a3,a2
ffffffffc0200cbc:	4388                	lw	a0,0(a5)
ffffffffc0200cbe:	4294                	lw	a3,0(a3)
        size <<= 1; // 增加页数
ffffffffc0200cc0:	0017181b          	slliw	a6,a4,0x1
            buddy_page[index] = size; // 设置当前节点的页数
ffffffffc0200cc4:	02059713          	slli	a4,a1,0x20
ffffffffc0200cc8:	01e75793          	srli	a5,a4,0x1e
        if(buddy_page[LEFT_CHILD(index)] + buddy_page[RIGHT_CHILD(index)] == size){ // 如果子节点的页数等于当前节点页数
ffffffffc0200ccc:	00a688bb          	addw	a7,a3,a0
        size <<= 1; // 增加页数
ffffffffc0200cd0:	0008071b          	sext.w	a4,a6
            buddy_page[index] = size; // 设置当前节点的页数
ffffffffc0200cd4:	97b2                	add	a5,a5,a2
        if(buddy_page[LEFT_CHILD(index)] + buddy_page[RIGHT_CHILD(index)] == size){ // 如果子节点的页数等于当前节点页数
ffffffffc0200cd6:	00e88663          	beq	a7,a4,ffffffffc0200ce2 <buddy_free_pages+0xd4>
            buddy_page[index] = MAX(buddy_page[LEFT_CHILD(index)], buddy_page[RIGHT_CHILD(index)]); // 否则取最大值
ffffffffc0200cda:	8836                	mv	a6,a3
ffffffffc0200cdc:	00a6f363          	bgeu	a3,a0,ffffffffc0200ce2 <buddy_free_pages+0xd4>
ffffffffc0200ce0:	882a                	mv	a6,a0
ffffffffc0200ce2:	0107a023          	sw	a6,0(a5)
    while((index = PARENT(index)) > 0){ // 更新所有父节点
ffffffffc0200ce6:	0015d69b          	srliw	a3,a1,0x1
ffffffffc0200cea:	0005879b          	sext.w	a5,a1
ffffffffc0200cee:	fad5                	bnez	a3,ffffffffc0200ca2 <buddy_free_pages+0x94>
}
ffffffffc0200cf0:	60a2                	ld	ra,8(sp)
ffffffffc0200cf2:	0141                	addi	sp,sp,16
ffffffffc0200cf4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面未被保留且未设置属性
ffffffffc0200cf6:	00001697          	auipc	a3,0x1
ffffffffc0200cfa:	2ba68693          	addi	a3,a3,698 # ffffffffc0201fb0 <commands+0x6d0>
ffffffffc0200cfe:	00001617          	auipc	a2,0x1
ffffffffc0200d02:	0e260613          	addi	a2,a2,226 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200d06:	06f00593          	li	a1,111
ffffffffc0200d0a:	00001517          	auipc	a0,0x1
ffffffffc0200d0e:	0ee50513          	addi	a0,a0,238 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200d12:	e9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200d16:	00001697          	auipc	a3,0x1
ffffffffc0200d1a:	0c268693          	addi	a3,a3,194 # ffffffffc0201dd8 <commands+0x4f8>
ffffffffc0200d1e:	00001617          	auipc	a2,0x1
ffffffffc0200d22:	0c260613          	addi	a2,a2,194 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200d26:	06c00593          	li	a1,108
ffffffffc0200d2a:	00001517          	auipc	a0,0x1
ffffffffc0200d2e:	0ce50513          	addi	a0,a0,206 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200d32:	e7aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d36 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200d36:	1141                	addi	sp,sp,-16
ffffffffc0200d38:	e406                	sd	ra,8(sp)
    assert((n > 0));
ffffffffc0200d3a:	18058663          	beqz	a1,ffffffffc0200ec6 <buddy_init_memmap+0x190>
ffffffffc0200d3e:	46f5                	li	a3,29
ffffffffc0200d40:	4601                	li	a2,0
ffffffffc0200d42:	4705                	li	a4,1
ffffffffc0200d44:	a801                	j	ffffffffc0200d54 <buddy_init_memmap+0x1e>
    for (int i = 1;
ffffffffc0200d46:	36fd                	addiw	a3,a3,-1
         i++, useable_page_num <<= 1); // 逐步增加可用页数，直到达到最大深度或超出n
ffffffffc0200d48:	0017179b          	slliw	a5,a4,0x1
ffffffffc0200d4c:	4605                	li	a2,1
    for (int i = 1;
ffffffffc0200d4e:	14068363          	beqz	a3,ffffffffc0200e94 <buddy_init_memmap+0x15e>
         i++, useable_page_num <<= 1); // 逐步增加可用页数，直到达到最大深度或超出n
ffffffffc0200d52:	873e                	mv	a4,a5
         (i < BUDDY_MAX_DEPTH) && (useable_page_num + (useable_page_num >> 9) < n);
ffffffffc0200d54:	0097579b          	srliw	a5,a4,0x9
ffffffffc0200d58:	9fb9                	addw	a5,a5,a4
ffffffffc0200d5a:	1782                	slli	a5,a5,0x20
ffffffffc0200d5c:	9381                	srli	a5,a5,0x20
ffffffffc0200d5e:	feb7e4e3          	bltu	a5,a1,ffffffffc0200d46 <buddy_init_memmap+0x10>
ffffffffc0200d62:	12060463          	beqz	a2,ffffffffc0200e8a <buddy_init_memmap+0x154>
    buddy_page_num = (useable_page_num >> 9) + 1; // 计算管理页的数量
ffffffffc0200d66:	00a7579b          	srliw	a5,a4,0xa
ffffffffc0200d6a:	2785                	addiw	a5,a5,1
    useable_page_base = base + buddy_page_num;
ffffffffc0200d6c:	02079693          	slli	a3,a5,0x20
ffffffffc0200d70:	9281                	srli	a3,a3,0x20
ffffffffc0200d72:	00269613          	slli	a2,a3,0x2
ffffffffc0200d76:	9636                	add	a2,a2,a3
    useable_page_num >>= 1; // 可用页数向下取整
ffffffffc0200d78:	0017571b          	srliw	a4,a4,0x1
    useable_page_base = base + buddy_page_num;
ffffffffc0200d7c:	060e                	slli	a2,a2,0x3
    buddy_page_num = (useable_page_num >> 9) + 1; // 计算管理页的数量
ffffffffc0200d7e:	00005697          	auipc	a3,0x5
ffffffffc0200d82:	6aa68693          	addi	a3,a3,1706 # ffffffffc0206428 <buddy_page_num>
    useable_page_base = base + buddy_page_num;
ffffffffc0200d86:	962a                	add	a2,a2,a0
    buddy_page_num = (useable_page_num >> 9) + 1; // 计算管理页的数量
ffffffffc0200d88:	c29c                	sw	a5,0(a3)
    useable_page_num >>= 1; // 可用页数向下取整
ffffffffc0200d8a:	00005897          	auipc	a7,0x5
ffffffffc0200d8e:	6ae88893          	addi	a7,a7,1710 # ffffffffc0206438 <useable_page_num>
    useable_page_base = base + buddy_page_num;
ffffffffc0200d92:	00005797          	auipc	a5,0x5
ffffffffc0200d96:	68c7bf23          	sd	a2,1694(a5) # ffffffffc0206430 <useable_page_base>
    useable_page_num >>= 1; // 可用页数向下取整
ffffffffc0200d9a:	00e8a023          	sw	a4,0(a7)
    for (int i = 0; i != buddy_page_num; i++){
ffffffffc0200d9e:	00850793          	addi	a5,a0,8
ffffffffc0200da2:	4701                	li	a4,0
ffffffffc0200da4:	4805                	li	a6,1
ffffffffc0200da6:	4107b02f          	amoor.d	zero,a6,(a5)
ffffffffc0200daa:	4290                	lw	a2,0(a3)
ffffffffc0200dac:	2705                	addiw	a4,a4,1
ffffffffc0200dae:	02878793          	addi	a5,a5,40
ffffffffc0200db2:	fee61ae3          	bne	a2,a4,ffffffffc0200da6 <buddy_init_memmap+0x70>
    for (int i = buddy_page_num; i != n; i++){
ffffffffc0200db6:	1702                	slli	a4,a4,0x20
ffffffffc0200db8:	9301                	srli	a4,a4,0x20
ffffffffc0200dba:	02e58563          	beq	a1,a4,ffffffffc0200de4 <buddy_init_memmap+0xae>
ffffffffc0200dbe:	00271793          	slli	a5,a4,0x2
ffffffffc0200dc2:	97ba                	add	a5,a5,a4
ffffffffc0200dc4:	078e                	slli	a5,a5,0x3
ffffffffc0200dc6:	07a1                	addi	a5,a5,8
ffffffffc0200dc8:	97aa                	add	a5,a5,a0
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200dca:	5679                	li	a2,-2
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dcc:	4689                	li	a3,2
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200dce:	60c7b02f          	amoand.d	zero,a2,(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dd2:	40d7b02f          	amoor.d	zero,a3,(a5)
ffffffffc0200dd6:	fe07ac23          	sw	zero,-8(a5)
ffffffffc0200dda:	0705                	addi	a4,a4,1
ffffffffc0200ddc:	02878793          	addi	a5,a5,40
ffffffffc0200de0:	fee597e3          	bne	a1,a4,ffffffffc0200dce <buddy_init_memmap+0x98>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200de4:	00005697          	auipc	a3,0x5
ffffffffc0200de8:	6646b683          	ld	a3,1636(a3) # ffffffffc0206448 <pages>
ffffffffc0200dec:	40d506b3          	sub	a3,a0,a3
ffffffffc0200df0:	00001617          	auipc	a2,0x1
ffffffffc0200df4:	5d863603          	ld	a2,1496(a2) # ffffffffc02023c8 <error_string+0x38>
ffffffffc0200df8:	868d                	srai	a3,a3,0x3
ffffffffc0200dfa:	02c686b3          	mul	a3,a3,a2
ffffffffc0200dfe:	00001617          	auipc	a2,0x1
ffffffffc0200e02:	5d263603          	ld	a2,1490(a2) # ffffffffc02023d0 <nbase>
    buddy_page = (unsigned int*)KADDR(page2pa(base)); // 获取管理页地址
ffffffffc0200e06:	00005717          	auipc	a4,0x5
ffffffffc0200e0a:	63a73703          	ld	a4,1594(a4) # ffffffffc0206440 <npage>
ffffffffc0200e0e:	96b2                	add	a3,a3,a2
ffffffffc0200e10:	00c69793          	slli	a5,a3,0xc
ffffffffc0200e14:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e16:	06b2                	slli	a3,a3,0xc
ffffffffc0200e18:	08e7fb63          	bgeu	a5,a4,ffffffffc0200eae <buddy_init_memmap+0x178>
    for (int i = useable_page_num; i < useable_page_num << 1; i++){
ffffffffc0200e1c:	0008a783          	lw	a5,0(a7)
    buddy_page = (unsigned int*)KADDR(page2pa(base)); // 获取管理页地址
ffffffffc0200e20:	00005617          	auipc	a2,0x5
ffffffffc0200e24:	64863603          	ld	a2,1608(a2) # ffffffffc0206468 <va_pa_offset>
ffffffffc0200e28:	9636                	add	a2,a2,a3
ffffffffc0200e2a:	00005717          	auipc	a4,0x5
ffffffffc0200e2e:	5ec73b23          	sd	a2,1526(a4) # ffffffffc0206420 <buddy_page>
    for (int i = useable_page_num; i < useable_page_num << 1; i++){
ffffffffc0200e32:	0017959b          	slliw	a1,a5,0x1
ffffffffc0200e36:	0007871b          	sext.w	a4,a5
ffffffffc0200e3a:	02b7f263          	bgeu	a5,a1,ffffffffc0200e5e <buddy_init_memmap+0x128>
ffffffffc0200e3e:	40f586bb          	subw	a3,a1,a5
ffffffffc0200e42:	36fd                	addiw	a3,a3,-1
ffffffffc0200e44:	1682                	slli	a3,a3,0x20
ffffffffc0200e46:	9281                	srli	a3,a3,0x20
ffffffffc0200e48:	96ba                	add	a3,a3,a4
ffffffffc0200e4a:	0685                	addi	a3,a3,1
ffffffffc0200e4c:	070a                	slli	a4,a4,0x2
ffffffffc0200e4e:	068a                	slli	a3,a3,0x2
ffffffffc0200e50:	9732                	add	a4,a4,a2
ffffffffc0200e52:	96b2                	add	a3,a3,a2
        buddy_page[i] = 1; // 初始化页数为1
ffffffffc0200e54:	4585                	li	a1,1
ffffffffc0200e56:	c30c                	sw	a1,0(a4)
    for (int i = useable_page_num; i < useable_page_num << 1; i++){
ffffffffc0200e58:	0711                	addi	a4,a4,4
ffffffffc0200e5a:	fee69ee3          	bne	a3,a4,ffffffffc0200e56 <buddy_init_memmap+0x120>
    for (int i = useable_page_num - 1; i > 0; i--){
ffffffffc0200e5e:	fff7869b          	addiw	a3,a5,-1
ffffffffc0200e62:	87b6                	mv	a5,a3
ffffffffc0200e64:	02d05063          	blez	a3,ffffffffc0200e84 <buddy_init_memmap+0x14e>
ffffffffc0200e68:	068a                	slli	a3,a3,0x2
ffffffffc0200e6a:	0017979b          	slliw	a5,a5,0x1
ffffffffc0200e6e:	96b2                	add	a3,a3,a2
        buddy_page[i] = buddy_page[i << 1] << 1; // 更新父节点的页数
ffffffffc0200e70:	00279713          	slli	a4,a5,0x2
ffffffffc0200e74:	9732                	add	a4,a4,a2
ffffffffc0200e76:	4318                	lw	a4,0(a4)
    for (int i = useable_page_num - 1; i > 0; i--){
ffffffffc0200e78:	16f1                	addi	a3,a3,-4
ffffffffc0200e7a:	37f9                	addiw	a5,a5,-2
        buddy_page[i] = buddy_page[i << 1] << 1; // 更新父节点的页数
ffffffffc0200e7c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200e80:	c2d8                	sw	a4,4(a3)
    for (int i = useable_page_num - 1; i > 0; i--){
ffffffffc0200e82:	f7fd                	bnez	a5,ffffffffc0200e70 <buddy_init_memmap+0x13a>
}
ffffffffc0200e84:	60a2                	ld	ra,8(sp)
ffffffffc0200e86:	0141                	addi	sp,sp,16
ffffffffc0200e88:	8082                	ret
         (i < BUDDY_MAX_DEPTH) && (useable_page_num + (useable_page_num >> 9) < n);
ffffffffc0200e8a:	02800613          	li	a2,40
ffffffffc0200e8e:	4785                	li	a5,1
ffffffffc0200e90:	4701                	li	a4,0
ffffffffc0200e92:	b5f5                	j	ffffffffc0200d7e <buddy_init_memmap+0x48>
    buddy_page_num = (useable_page_num >> 9) + 1; // 计算管理页的数量
ffffffffc0200e94:	00a7d79b          	srliw	a5,a5,0xa
ffffffffc0200e98:	2785                	addiw	a5,a5,1
    useable_page_base = base + buddy_page_num;
ffffffffc0200e9a:	02079693          	slli	a3,a5,0x20
ffffffffc0200e9e:	9281                	srli	a3,a3,0x20
ffffffffc0200ea0:	00269613          	slli	a2,a3,0x2
    useable_page_num >>= 1; // 可用页数向下取整
ffffffffc0200ea4:	1706                	slli	a4,a4,0x21
    useable_page_base = base + buddy_page_num;
ffffffffc0200ea6:	9636                	add	a2,a2,a3
    useable_page_num >>= 1; // 可用页数向下取整
ffffffffc0200ea8:	9305                	srli	a4,a4,0x21
    useable_page_base = base + buddy_page_num;
ffffffffc0200eaa:	060e                	slli	a2,a2,0x3
ffffffffc0200eac:	bdc9                	j	ffffffffc0200d7e <buddy_init_memmap+0x48>
    buddy_page = (unsigned int*)KADDR(page2pa(base)); // 获取管理页地址
ffffffffc0200eae:	00001617          	auipc	a2,0x1
ffffffffc0200eb2:	13260613          	addi	a2,a2,306 # ffffffffc0201fe0 <commands+0x700>
ffffffffc0200eb6:	03400593          	li	a1,52
ffffffffc0200eba:	00001517          	auipc	a0,0x1
ffffffffc0200ebe:	f3e50513          	addi	a0,a0,-194 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200ec2:	ceaff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((n > 0));
ffffffffc0200ec6:	00001697          	auipc	a3,0x1
ffffffffc0200eca:	11268693          	addi	a3,a3,274 # ffffffffc0201fd8 <commands+0x6f8>
ffffffffc0200ece:	00001617          	auipc	a2,0x1
ffffffffc0200ed2:	f1260613          	addi	a2,a2,-238 # ffffffffc0201de0 <commands+0x500>
ffffffffc0200ed6:	45ed                	li	a1,27
ffffffffc0200ed8:	00001517          	auipc	a0,0x1
ffffffffc0200edc:	f2050513          	addi	a0,a0,-224 # ffffffffc0201df8 <commands+0x518>
ffffffffc0200ee0:	cccff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ee4 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ee4:	100027f3          	csrr	a5,sstatus
ffffffffc0200ee8:	8b89                	andi	a5,a5,2
ffffffffc0200eea:	e799                	bnez	a5,ffffffffc0200ef8 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200eec:	00005797          	auipc	a5,0x5
ffffffffc0200ef0:	5647b783          	ld	a5,1380(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200ef4:	6f9c                	ld	a5,24(a5)
ffffffffc0200ef6:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200ef8:	1141                	addi	sp,sp,-16
ffffffffc0200efa:	e406                	sd	ra,8(sp)
ffffffffc0200efc:	e022                	sd	s0,0(sp)
ffffffffc0200efe:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200f00:	d5eff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200f04:	00005797          	auipc	a5,0x5
ffffffffc0200f08:	54c7b783          	ld	a5,1356(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f0c:	6f9c                	ld	a5,24(a5)
ffffffffc0200f0e:	8522                	mv	a0,s0
ffffffffc0200f10:	9782                	jalr	a5
ffffffffc0200f12:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200f14:	d44ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200f18:	60a2                	ld	ra,8(sp)
ffffffffc0200f1a:	8522                	mv	a0,s0
ffffffffc0200f1c:	6402                	ld	s0,0(sp)
ffffffffc0200f1e:	0141                	addi	sp,sp,16
ffffffffc0200f20:	8082                	ret

ffffffffc0200f22 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f22:	100027f3          	csrr	a5,sstatus
ffffffffc0200f26:	8b89                	andi	a5,a5,2
ffffffffc0200f28:	e799                	bnez	a5,ffffffffc0200f36 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200f2a:	00005797          	auipc	a5,0x5
ffffffffc0200f2e:	5267b783          	ld	a5,1318(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f32:	739c                	ld	a5,32(a5)
ffffffffc0200f34:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200f36:	1101                	addi	sp,sp,-32
ffffffffc0200f38:	ec06                	sd	ra,24(sp)
ffffffffc0200f3a:	e822                	sd	s0,16(sp)
ffffffffc0200f3c:	e426                	sd	s1,8(sp)
ffffffffc0200f3e:	842a                	mv	s0,a0
ffffffffc0200f40:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200f42:	d1cff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200f46:	00005797          	auipc	a5,0x5
ffffffffc0200f4a:	50a7b783          	ld	a5,1290(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f4e:	739c                	ld	a5,32(a5)
ffffffffc0200f50:	85a6                	mv	a1,s1
ffffffffc0200f52:	8522                	mv	a0,s0
ffffffffc0200f54:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200f56:	6442                	ld	s0,16(sp)
ffffffffc0200f58:	60e2                	ld	ra,24(sp)
ffffffffc0200f5a:	64a2                	ld	s1,8(sp)
ffffffffc0200f5c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200f5e:	cfaff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0200f62 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200f62:	100027f3          	csrr	a5,sstatus
ffffffffc0200f66:	8b89                	andi	a5,a5,2
ffffffffc0200f68:	e799                	bnez	a5,ffffffffc0200f76 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f6a:	00005797          	auipc	a5,0x5
ffffffffc0200f6e:	4e67b783          	ld	a5,1254(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f72:	779c                	ld	a5,40(a5)
ffffffffc0200f74:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0200f76:	1141                	addi	sp,sp,-16
ffffffffc0200f78:	e406                	sd	ra,8(sp)
ffffffffc0200f7a:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0200f7c:	ce2ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0200f80:	00005797          	auipc	a5,0x5
ffffffffc0200f84:	4d07b783          	ld	a5,1232(a5) # ffffffffc0206450 <pmm_manager>
ffffffffc0200f88:	779c                	ld	a5,40(a5)
ffffffffc0200f8a:	9782                	jalr	a5
ffffffffc0200f8c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0200f8e:	ccaff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0200f92:	60a2                	ld	ra,8(sp)
ffffffffc0200f94:	8522                	mv	a0,s0
ffffffffc0200f96:	6402                	ld	s0,0(sp)
ffffffffc0200f98:	0141                	addi	sp,sp,16
ffffffffc0200f9a:	8082                	ret

ffffffffc0200f9c <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200f9c:	00001797          	auipc	a5,0x1
ffffffffc0200fa0:	08478793          	addi	a5,a5,132 # ffffffffc0202020 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fa4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200fa6:	1101                	addi	sp,sp,-32
ffffffffc0200fa8:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200faa:	00001517          	auipc	a0,0x1
ffffffffc0200fae:	0ae50513          	addi	a0,a0,174 # ffffffffc0202058 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fb2:	00005497          	auipc	s1,0x5
ffffffffc0200fb6:	49e48493          	addi	s1,s1,1182 # ffffffffc0206450 <pmm_manager>
void pmm_init(void) {
ffffffffc0200fba:	ec06                	sd	ra,24(sp)
ffffffffc0200fbc:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200fbe:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200fc0:	8f2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200fc4:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fc6:	00005417          	auipc	s0,0x5
ffffffffc0200fca:	4a240413          	addi	s0,s0,1186 # ffffffffc0206468 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200fce:	679c                	ld	a5,8(a5)
ffffffffc0200fd0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fd2:	57f5                	li	a5,-3
ffffffffc0200fd4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200fd6:	00001517          	auipc	a0,0x1
ffffffffc0200fda:	09a50513          	addi	a0,a0,154 # ffffffffc0202070 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200fde:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200fe0:	8d2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200fe4:	46c5                	li	a3,17
ffffffffc0200fe6:	06ee                	slli	a3,a3,0x1b
ffffffffc0200fe8:	40100613          	li	a2,1025
ffffffffc0200fec:	16fd                	addi	a3,a3,-1
ffffffffc0200fee:	07e005b7          	lui	a1,0x7e00
ffffffffc0200ff2:	0656                	slli	a2,a2,0x15
ffffffffc0200ff4:	00001517          	auipc	a0,0x1
ffffffffc0200ff8:	09450513          	addi	a0,a0,148 # ffffffffc0202088 <buddy_pmm_manager+0x68>
ffffffffc0200ffc:	8b6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201000:	777d                	lui	a4,0xfffff
ffffffffc0201002:	00006797          	auipc	a5,0x6
ffffffffc0201006:	47578793          	addi	a5,a5,1141 # ffffffffc0207477 <end+0xfff>
ffffffffc020100a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020100c:	00005517          	auipc	a0,0x5
ffffffffc0201010:	43450513          	addi	a0,a0,1076 # ffffffffc0206440 <npage>
ffffffffc0201014:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201018:	00005597          	auipc	a1,0x5
ffffffffc020101c:	43058593          	addi	a1,a1,1072 # ffffffffc0206448 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201020:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201022:	e19c                	sd	a5,0(a1)
ffffffffc0201024:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201026:	4701                	li	a4,0
ffffffffc0201028:	4885                	li	a7,1
ffffffffc020102a:	fff80837          	lui	a6,0xfff80
ffffffffc020102e:	a011                	j	ffffffffc0201032 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201030:	619c                	ld	a5,0(a1)
ffffffffc0201032:	97b6                	add	a5,a5,a3
ffffffffc0201034:	07a1                	addi	a5,a5,8
ffffffffc0201036:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020103a:	611c                	ld	a5,0(a0)
ffffffffc020103c:	0705                	addi	a4,a4,1
ffffffffc020103e:	02868693          	addi	a3,a3,40
ffffffffc0201042:	01078633          	add	a2,a5,a6
ffffffffc0201046:	fec765e3          	bltu	a4,a2,ffffffffc0201030 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020104a:	6190                	ld	a2,0(a1)
ffffffffc020104c:	00279713          	slli	a4,a5,0x2
ffffffffc0201050:	973e                	add	a4,a4,a5
ffffffffc0201052:	fec006b7          	lui	a3,0xfec00
ffffffffc0201056:	070e                	slli	a4,a4,0x3
ffffffffc0201058:	96b2                	add	a3,a3,a2
ffffffffc020105a:	96ba                	add	a3,a3,a4
ffffffffc020105c:	c0200737          	lui	a4,0xc0200
ffffffffc0201060:	08e6ef63          	bltu	a3,a4,ffffffffc02010fe <pmm_init+0x162>
ffffffffc0201064:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201066:	45c5                	li	a1,17
ffffffffc0201068:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020106a:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020106c:	04b6e863          	bltu	a3,a1,ffffffffc02010bc <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201070:	609c                	ld	a5,0(s1)
ffffffffc0201072:	7b9c                	ld	a5,48(a5)
ffffffffc0201074:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201076:	00001517          	auipc	a0,0x1
ffffffffc020107a:	0aa50513          	addi	a0,a0,170 # ffffffffc0202120 <buddy_pmm_manager+0x100>
ffffffffc020107e:	834ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201082:	00004597          	auipc	a1,0x4
ffffffffc0201086:	f7e58593          	addi	a1,a1,-130 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020108a:	00005797          	auipc	a5,0x5
ffffffffc020108e:	3cb7bb23          	sd	a1,982(a5) # ffffffffc0206460 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201092:	c02007b7          	lui	a5,0xc0200
ffffffffc0201096:	08f5e063          	bltu	a1,a5,ffffffffc0201116 <pmm_init+0x17a>
ffffffffc020109a:	6010                	ld	a2,0(s0)
}
ffffffffc020109c:	6442                	ld	s0,16(sp)
ffffffffc020109e:	60e2                	ld	ra,24(sp)
ffffffffc02010a0:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02010a2:	40c58633          	sub	a2,a1,a2
ffffffffc02010a6:	00005797          	auipc	a5,0x5
ffffffffc02010aa:	3ac7b923          	sd	a2,946(a5) # ffffffffc0206458 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010ae:	00001517          	auipc	a0,0x1
ffffffffc02010b2:	09250513          	addi	a0,a0,146 # ffffffffc0202140 <buddy_pmm_manager+0x120>
}
ffffffffc02010b6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010b8:	ffbfe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02010bc:	6705                	lui	a4,0x1
ffffffffc02010be:	177d                	addi	a4,a4,-1
ffffffffc02010c0:	96ba                	add	a3,a3,a4
ffffffffc02010c2:	777d                	lui	a4,0xfffff
ffffffffc02010c4:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010c6:	00c6d513          	srli	a0,a3,0xc
ffffffffc02010ca:	00f57e63          	bgeu	a0,a5,ffffffffc02010e6 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02010ce:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02010d0:	982a                	add	a6,a6,a0
ffffffffc02010d2:	00281513          	slli	a0,a6,0x2
ffffffffc02010d6:	9542                	add	a0,a0,a6
ffffffffc02010d8:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010da:	8d95                	sub	a1,a1,a3
ffffffffc02010dc:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02010de:	81b1                	srli	a1,a1,0xc
ffffffffc02010e0:	9532                	add	a0,a0,a2
ffffffffc02010e2:	9782                	jalr	a5
}
ffffffffc02010e4:	b771                	j	ffffffffc0201070 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02010e6:	00001617          	auipc	a2,0x1
ffffffffc02010ea:	00a60613          	addi	a2,a2,10 # ffffffffc02020f0 <buddy_pmm_manager+0xd0>
ffffffffc02010ee:	06b00593          	li	a1,107
ffffffffc02010f2:	00001517          	auipc	a0,0x1
ffffffffc02010f6:	01e50513          	addi	a0,a0,30 # ffffffffc0202110 <buddy_pmm_manager+0xf0>
ffffffffc02010fa:	ab2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010fe:	00001617          	auipc	a2,0x1
ffffffffc0201102:	fba60613          	addi	a2,a2,-70 # ffffffffc02020b8 <buddy_pmm_manager+0x98>
ffffffffc0201106:	07100593          	li	a1,113
ffffffffc020110a:	00001517          	auipc	a0,0x1
ffffffffc020110e:	fd650513          	addi	a0,a0,-42 # ffffffffc02020e0 <buddy_pmm_manager+0xc0>
ffffffffc0201112:	a9aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201116:	86ae                	mv	a3,a1
ffffffffc0201118:	00001617          	auipc	a2,0x1
ffffffffc020111c:	fa060613          	addi	a2,a2,-96 # ffffffffc02020b8 <buddy_pmm_manager+0x98>
ffffffffc0201120:	08c00593          	li	a1,140
ffffffffc0201124:	00001517          	auipc	a0,0x1
ffffffffc0201128:	fbc50513          	addi	a0,a0,-68 # ffffffffc02020e0 <buddy_pmm_manager+0xc0>
ffffffffc020112c:	a80ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201130 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201130:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201134:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201136:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020113a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020113c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201140:	f022                	sd	s0,32(sp)
ffffffffc0201142:	ec26                	sd	s1,24(sp)
ffffffffc0201144:	e84a                	sd	s2,16(sp)
ffffffffc0201146:	f406                	sd	ra,40(sp)
ffffffffc0201148:	e44e                	sd	s3,8(sp)
ffffffffc020114a:	84aa                	mv	s1,a0
ffffffffc020114c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020114e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201152:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201154:	03067e63          	bgeu	a2,a6,ffffffffc0201190 <printnum+0x60>
ffffffffc0201158:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020115a:	00805763          	blez	s0,ffffffffc0201168 <printnum+0x38>
ffffffffc020115e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201160:	85ca                	mv	a1,s2
ffffffffc0201162:	854e                	mv	a0,s3
ffffffffc0201164:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201166:	fc65                	bnez	s0,ffffffffc020115e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201168:	1a02                	slli	s4,s4,0x20
ffffffffc020116a:	00001797          	auipc	a5,0x1
ffffffffc020116e:	01678793          	addi	a5,a5,22 # ffffffffc0202180 <buddy_pmm_manager+0x160>
ffffffffc0201172:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201176:	9a3e                	add	s4,s4,a5
}
ffffffffc0201178:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020117a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020117e:	70a2                	ld	ra,40(sp)
ffffffffc0201180:	69a2                	ld	s3,8(sp)
ffffffffc0201182:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201184:	85ca                	mv	a1,s2
ffffffffc0201186:	87a6                	mv	a5,s1
}
ffffffffc0201188:	6942                	ld	s2,16(sp)
ffffffffc020118a:	64e2                	ld	s1,24(sp)
ffffffffc020118c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020118e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201190:	03065633          	divu	a2,a2,a6
ffffffffc0201194:	8722                	mv	a4,s0
ffffffffc0201196:	f9bff0ef          	jal	ra,ffffffffc0201130 <printnum>
ffffffffc020119a:	b7f9                	j	ffffffffc0201168 <printnum+0x38>

ffffffffc020119c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020119c:	7119                	addi	sp,sp,-128
ffffffffc020119e:	f4a6                	sd	s1,104(sp)
ffffffffc02011a0:	f0ca                	sd	s2,96(sp)
ffffffffc02011a2:	ecce                	sd	s3,88(sp)
ffffffffc02011a4:	e8d2                	sd	s4,80(sp)
ffffffffc02011a6:	e4d6                	sd	s5,72(sp)
ffffffffc02011a8:	e0da                	sd	s6,64(sp)
ffffffffc02011aa:	fc5e                	sd	s7,56(sp)
ffffffffc02011ac:	f06a                	sd	s10,32(sp)
ffffffffc02011ae:	fc86                	sd	ra,120(sp)
ffffffffc02011b0:	f8a2                	sd	s0,112(sp)
ffffffffc02011b2:	f862                	sd	s8,48(sp)
ffffffffc02011b4:	f466                	sd	s9,40(sp)
ffffffffc02011b6:	ec6e                	sd	s11,24(sp)
ffffffffc02011b8:	892a                	mv	s2,a0
ffffffffc02011ba:	84ae                	mv	s1,a1
ffffffffc02011bc:	8d32                	mv	s10,a2
ffffffffc02011be:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011c0:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011c4:	5b7d                	li	s6,-1
ffffffffc02011c6:	00001a97          	auipc	s5,0x1
ffffffffc02011ca:	feea8a93          	addi	s5,s5,-18 # ffffffffc02021b4 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011ce:	00001b97          	auipc	s7,0x1
ffffffffc02011d2:	1c2b8b93          	addi	s7,s7,450 # ffffffffc0202390 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011d6:	000d4503          	lbu	a0,0(s10)
ffffffffc02011da:	001d0413          	addi	s0,s10,1
ffffffffc02011de:	01350a63          	beq	a0,s3,ffffffffc02011f2 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02011e2:	c121                	beqz	a0,ffffffffc0201222 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02011e4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011e6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02011e8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011ea:	fff44503          	lbu	a0,-1(s0)
ffffffffc02011ee:	ff351ae3          	bne	a0,s3,ffffffffc02011e2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011f2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02011f6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02011fa:	4c81                	li	s9,0
ffffffffc02011fc:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02011fe:	5c7d                	li	s8,-1
ffffffffc0201200:	5dfd                	li	s11,-1
ffffffffc0201202:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201206:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201208:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020120c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201210:	00140d13          	addi	s10,s0,1
ffffffffc0201214:	04b56263          	bltu	a0,a1,ffffffffc0201258 <vprintfmt+0xbc>
ffffffffc0201218:	058a                	slli	a1,a1,0x2
ffffffffc020121a:	95d6                	add	a1,a1,s5
ffffffffc020121c:	4194                	lw	a3,0(a1)
ffffffffc020121e:	96d6                	add	a3,a3,s5
ffffffffc0201220:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201222:	70e6                	ld	ra,120(sp)
ffffffffc0201224:	7446                	ld	s0,112(sp)
ffffffffc0201226:	74a6                	ld	s1,104(sp)
ffffffffc0201228:	7906                	ld	s2,96(sp)
ffffffffc020122a:	69e6                	ld	s3,88(sp)
ffffffffc020122c:	6a46                	ld	s4,80(sp)
ffffffffc020122e:	6aa6                	ld	s5,72(sp)
ffffffffc0201230:	6b06                	ld	s6,64(sp)
ffffffffc0201232:	7be2                	ld	s7,56(sp)
ffffffffc0201234:	7c42                	ld	s8,48(sp)
ffffffffc0201236:	7ca2                	ld	s9,40(sp)
ffffffffc0201238:	7d02                	ld	s10,32(sp)
ffffffffc020123a:	6de2                	ld	s11,24(sp)
ffffffffc020123c:	6109                	addi	sp,sp,128
ffffffffc020123e:	8082                	ret
            padc = '0';
ffffffffc0201240:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201242:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201246:	846a                	mv	s0,s10
ffffffffc0201248:	00140d13          	addi	s10,s0,1
ffffffffc020124c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201250:	0ff5f593          	zext.b	a1,a1
ffffffffc0201254:	fcb572e3          	bgeu	a0,a1,ffffffffc0201218 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201258:	85a6                	mv	a1,s1
ffffffffc020125a:	02500513          	li	a0,37
ffffffffc020125e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201260:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201264:	8d22                	mv	s10,s0
ffffffffc0201266:	f73788e3          	beq	a5,s3,ffffffffc02011d6 <vprintfmt+0x3a>
ffffffffc020126a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020126e:	1d7d                	addi	s10,s10,-1
ffffffffc0201270:	ff379de3          	bne	a5,s3,ffffffffc020126a <vprintfmt+0xce>
ffffffffc0201274:	b78d                	j	ffffffffc02011d6 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201276:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020127a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020127e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201280:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201284:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201288:	02d86463          	bltu	a6,a3,ffffffffc02012b0 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020128c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201290:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201294:	0186873b          	addw	a4,a3,s8
ffffffffc0201298:	0017171b          	slliw	a4,a4,0x1
ffffffffc020129c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020129e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02012a2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02012a4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02012a8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02012ac:	fed870e3          	bgeu	a6,a3,ffffffffc020128c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02012b0:	f40ddce3          	bgez	s11,ffffffffc0201208 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02012b4:	8de2                	mv	s11,s8
ffffffffc02012b6:	5c7d                	li	s8,-1
ffffffffc02012b8:	bf81                	j	ffffffffc0201208 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02012ba:	fffdc693          	not	a3,s11
ffffffffc02012be:	96fd                	srai	a3,a3,0x3f
ffffffffc02012c0:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012c4:	00144603          	lbu	a2,1(s0)
ffffffffc02012c8:	2d81                	sext.w	s11,s11
ffffffffc02012ca:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012cc:	bf35                	j	ffffffffc0201208 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02012ce:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012d2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02012d6:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012d8:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02012da:	bfd9                	j	ffffffffc02012b0 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02012dc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02012de:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02012e2:	01174463          	blt	a4,a7,ffffffffc02012ea <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02012e6:	1a088e63          	beqz	a7,ffffffffc02014a2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02012ea:	000a3603          	ld	a2,0(s4)
ffffffffc02012ee:	46c1                	li	a3,16
ffffffffc02012f0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02012f2:	2781                	sext.w	a5,a5
ffffffffc02012f4:	876e                	mv	a4,s11
ffffffffc02012f6:	85a6                	mv	a1,s1
ffffffffc02012f8:	854a                	mv	a0,s2
ffffffffc02012fa:	e37ff0ef          	jal	ra,ffffffffc0201130 <printnum>
            break;
ffffffffc02012fe:	bde1                	j	ffffffffc02011d6 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201300:	000a2503          	lw	a0,0(s4)
ffffffffc0201304:	85a6                	mv	a1,s1
ffffffffc0201306:	0a21                	addi	s4,s4,8
ffffffffc0201308:	9902                	jalr	s2
            break;
ffffffffc020130a:	b5f1                	j	ffffffffc02011d6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020130c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020130e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201312:	01174463          	blt	a4,a7,ffffffffc020131a <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201316:	18088163          	beqz	a7,ffffffffc0201498 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020131a:	000a3603          	ld	a2,0(s4)
ffffffffc020131e:	46a9                	li	a3,10
ffffffffc0201320:	8a2e                	mv	s4,a1
ffffffffc0201322:	bfc1                	j	ffffffffc02012f2 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201324:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201328:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020132a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020132c:	bdf1                	j	ffffffffc0201208 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020132e:	85a6                	mv	a1,s1
ffffffffc0201330:	02500513          	li	a0,37
ffffffffc0201334:	9902                	jalr	s2
            break;
ffffffffc0201336:	b545                	j	ffffffffc02011d6 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201338:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020133c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020133e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201340:	b5e1                	j	ffffffffc0201208 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201342:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201344:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201348:	01174463          	blt	a4,a7,ffffffffc0201350 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020134c:	14088163          	beqz	a7,ffffffffc020148e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201350:	000a3603          	ld	a2,0(s4)
ffffffffc0201354:	46a1                	li	a3,8
ffffffffc0201356:	8a2e                	mv	s4,a1
ffffffffc0201358:	bf69                	j	ffffffffc02012f2 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020135a:	03000513          	li	a0,48
ffffffffc020135e:	85a6                	mv	a1,s1
ffffffffc0201360:	e03e                	sd	a5,0(sp)
ffffffffc0201362:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201364:	85a6                	mv	a1,s1
ffffffffc0201366:	07800513          	li	a0,120
ffffffffc020136a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020136c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020136e:	6782                	ld	a5,0(sp)
ffffffffc0201370:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201372:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201376:	bfb5                	j	ffffffffc02012f2 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201378:	000a3403          	ld	s0,0(s4)
ffffffffc020137c:	008a0713          	addi	a4,s4,8
ffffffffc0201380:	e03a                	sd	a4,0(sp)
ffffffffc0201382:	14040263          	beqz	s0,ffffffffc02014c6 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201386:	0fb05763          	blez	s11,ffffffffc0201474 <vprintfmt+0x2d8>
ffffffffc020138a:	02d00693          	li	a3,45
ffffffffc020138e:	0cd79163          	bne	a5,a3,ffffffffc0201450 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201392:	00044783          	lbu	a5,0(s0)
ffffffffc0201396:	0007851b          	sext.w	a0,a5
ffffffffc020139a:	cf85                	beqz	a5,ffffffffc02013d2 <vprintfmt+0x236>
ffffffffc020139c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013a0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013a4:	000c4563          	bltz	s8,ffffffffc02013ae <vprintfmt+0x212>
ffffffffc02013a8:	3c7d                	addiw	s8,s8,-1
ffffffffc02013aa:	036c0263          	beq	s8,s6,ffffffffc02013ce <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02013ae:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013b0:	0e0c8e63          	beqz	s9,ffffffffc02014ac <vprintfmt+0x310>
ffffffffc02013b4:	3781                	addiw	a5,a5,-32
ffffffffc02013b6:	0ef47b63          	bgeu	s0,a5,ffffffffc02014ac <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02013ba:	03f00513          	li	a0,63
ffffffffc02013be:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02013c0:	000a4783          	lbu	a5,0(s4)
ffffffffc02013c4:	3dfd                	addiw	s11,s11,-1
ffffffffc02013c6:	0a05                	addi	s4,s4,1
ffffffffc02013c8:	0007851b          	sext.w	a0,a5
ffffffffc02013cc:	ffe1                	bnez	a5,ffffffffc02013a4 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02013ce:	01b05963          	blez	s11,ffffffffc02013e0 <vprintfmt+0x244>
ffffffffc02013d2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02013d4:	85a6                	mv	a1,s1
ffffffffc02013d6:	02000513          	li	a0,32
ffffffffc02013da:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02013dc:	fe0d9be3          	bnez	s11,ffffffffc02013d2 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02013e0:	6a02                	ld	s4,0(sp)
ffffffffc02013e2:	bbd5                	j	ffffffffc02011d6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02013e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013e6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02013ea:	01174463          	blt	a4,a7,ffffffffc02013f2 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02013ee:	08088d63          	beqz	a7,ffffffffc0201488 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02013f2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02013f6:	0a044d63          	bltz	s0,ffffffffc02014b0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02013fa:	8622                	mv	a2,s0
ffffffffc02013fc:	8a66                	mv	s4,s9
ffffffffc02013fe:	46a9                	li	a3,10
ffffffffc0201400:	bdcd                	j	ffffffffc02012f2 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201402:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201406:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201408:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020140a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020140e:	8fb5                	xor	a5,a5,a3
ffffffffc0201410:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201414:	02d74163          	blt	a4,a3,ffffffffc0201436 <vprintfmt+0x29a>
ffffffffc0201418:	00369793          	slli	a5,a3,0x3
ffffffffc020141c:	97de                	add	a5,a5,s7
ffffffffc020141e:	639c                	ld	a5,0(a5)
ffffffffc0201420:	cb99                	beqz	a5,ffffffffc0201436 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201422:	86be                	mv	a3,a5
ffffffffc0201424:	00001617          	auipc	a2,0x1
ffffffffc0201428:	d8c60613          	addi	a2,a2,-628 # ffffffffc02021b0 <buddy_pmm_manager+0x190>
ffffffffc020142c:	85a6                	mv	a1,s1
ffffffffc020142e:	854a                	mv	a0,s2
ffffffffc0201430:	0ce000ef          	jal	ra,ffffffffc02014fe <printfmt>
ffffffffc0201434:	b34d                	j	ffffffffc02011d6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201436:	00001617          	auipc	a2,0x1
ffffffffc020143a:	d6a60613          	addi	a2,a2,-662 # ffffffffc02021a0 <buddy_pmm_manager+0x180>
ffffffffc020143e:	85a6                	mv	a1,s1
ffffffffc0201440:	854a                	mv	a0,s2
ffffffffc0201442:	0bc000ef          	jal	ra,ffffffffc02014fe <printfmt>
ffffffffc0201446:	bb41                	j	ffffffffc02011d6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201448:	00001417          	auipc	s0,0x1
ffffffffc020144c:	d5040413          	addi	s0,s0,-688 # ffffffffc0202198 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201450:	85e2                	mv	a1,s8
ffffffffc0201452:	8522                	mv	a0,s0
ffffffffc0201454:	e43e                	sd	a5,8(sp)
ffffffffc0201456:	1cc000ef          	jal	ra,ffffffffc0201622 <strnlen>
ffffffffc020145a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020145e:	01b05b63          	blez	s11,ffffffffc0201474 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201462:	67a2                	ld	a5,8(sp)
ffffffffc0201464:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201468:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020146a:	85a6                	mv	a1,s1
ffffffffc020146c:	8552                	mv	a0,s4
ffffffffc020146e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201470:	fe0d9ce3          	bnez	s11,ffffffffc0201468 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201474:	00044783          	lbu	a5,0(s0)
ffffffffc0201478:	00140a13          	addi	s4,s0,1
ffffffffc020147c:	0007851b          	sext.w	a0,a5
ffffffffc0201480:	d3a5                	beqz	a5,ffffffffc02013e0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201482:	05e00413          	li	s0,94
ffffffffc0201486:	bf39                	j	ffffffffc02013a4 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201488:	000a2403          	lw	s0,0(s4)
ffffffffc020148c:	b7ad                	j	ffffffffc02013f6 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020148e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201492:	46a1                	li	a3,8
ffffffffc0201494:	8a2e                	mv	s4,a1
ffffffffc0201496:	bdb1                	j	ffffffffc02012f2 <vprintfmt+0x156>
ffffffffc0201498:	000a6603          	lwu	a2,0(s4)
ffffffffc020149c:	46a9                	li	a3,10
ffffffffc020149e:	8a2e                	mv	s4,a1
ffffffffc02014a0:	bd89                	j	ffffffffc02012f2 <vprintfmt+0x156>
ffffffffc02014a2:	000a6603          	lwu	a2,0(s4)
ffffffffc02014a6:	46c1                	li	a3,16
ffffffffc02014a8:	8a2e                	mv	s4,a1
ffffffffc02014aa:	b5a1                	j	ffffffffc02012f2 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02014ac:	9902                	jalr	s2
ffffffffc02014ae:	bf09                	j	ffffffffc02013c0 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02014b0:	85a6                	mv	a1,s1
ffffffffc02014b2:	02d00513          	li	a0,45
ffffffffc02014b6:	e03e                	sd	a5,0(sp)
ffffffffc02014b8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02014ba:	6782                	ld	a5,0(sp)
ffffffffc02014bc:	8a66                	mv	s4,s9
ffffffffc02014be:	40800633          	neg	a2,s0
ffffffffc02014c2:	46a9                	li	a3,10
ffffffffc02014c4:	b53d                	j	ffffffffc02012f2 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02014c6:	03b05163          	blez	s11,ffffffffc02014e8 <vprintfmt+0x34c>
ffffffffc02014ca:	02d00693          	li	a3,45
ffffffffc02014ce:	f6d79de3          	bne	a5,a3,ffffffffc0201448 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02014d2:	00001417          	auipc	s0,0x1
ffffffffc02014d6:	cc640413          	addi	s0,s0,-826 # ffffffffc0202198 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014da:	02800793          	li	a5,40
ffffffffc02014de:	02800513          	li	a0,40
ffffffffc02014e2:	00140a13          	addi	s4,s0,1
ffffffffc02014e6:	bd6d                	j	ffffffffc02013a0 <vprintfmt+0x204>
ffffffffc02014e8:	00001a17          	auipc	s4,0x1
ffffffffc02014ec:	cb1a0a13          	addi	s4,s4,-847 # ffffffffc0202199 <buddy_pmm_manager+0x179>
ffffffffc02014f0:	02800513          	li	a0,40
ffffffffc02014f4:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014f8:	05e00413          	li	s0,94
ffffffffc02014fc:	b565                	j	ffffffffc02013a4 <vprintfmt+0x208>

ffffffffc02014fe <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014fe:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201500:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201504:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201506:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201508:	ec06                	sd	ra,24(sp)
ffffffffc020150a:	f83a                	sd	a4,48(sp)
ffffffffc020150c:	fc3e                	sd	a5,56(sp)
ffffffffc020150e:	e0c2                	sd	a6,64(sp)
ffffffffc0201510:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201512:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201514:	c89ff0ef          	jal	ra,ffffffffc020119c <vprintfmt>
}
ffffffffc0201518:	60e2                	ld	ra,24(sp)
ffffffffc020151a:	6161                	addi	sp,sp,80
ffffffffc020151c:	8082                	ret

ffffffffc020151e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020151e:	715d                	addi	sp,sp,-80
ffffffffc0201520:	e486                	sd	ra,72(sp)
ffffffffc0201522:	e0a6                	sd	s1,64(sp)
ffffffffc0201524:	fc4a                	sd	s2,56(sp)
ffffffffc0201526:	f84e                	sd	s3,48(sp)
ffffffffc0201528:	f452                	sd	s4,40(sp)
ffffffffc020152a:	f056                	sd	s5,32(sp)
ffffffffc020152c:	ec5a                	sd	s6,24(sp)
ffffffffc020152e:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201530:	c901                	beqz	a0,ffffffffc0201540 <readline+0x22>
ffffffffc0201532:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201534:	00001517          	auipc	a0,0x1
ffffffffc0201538:	c7c50513          	addi	a0,a0,-900 # ffffffffc02021b0 <buddy_pmm_manager+0x190>
ffffffffc020153c:	b77fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201540:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201542:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201544:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201546:	4aa9                	li	s5,10
ffffffffc0201548:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020154a:	00005b97          	auipc	s7,0x5
ffffffffc020154e:	ac6b8b93          	addi	s7,s7,-1338 # ffffffffc0206010 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201552:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201556:	bd5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020155a:	00054a63          	bltz	a0,ffffffffc020156e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020155e:	00a95a63          	bge	s2,a0,ffffffffc0201572 <readline+0x54>
ffffffffc0201562:	029a5263          	bge	s4,s1,ffffffffc0201586 <readline+0x68>
        c = getchar();
ffffffffc0201566:	bc5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020156a:	fe055ae3          	bgez	a0,ffffffffc020155e <readline+0x40>
            return NULL;
ffffffffc020156e:	4501                	li	a0,0
ffffffffc0201570:	a091                	j	ffffffffc02015b4 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201572:	03351463          	bne	a0,s3,ffffffffc020159a <readline+0x7c>
ffffffffc0201576:	e8a9                	bnez	s1,ffffffffc02015c8 <readline+0xaa>
        c = getchar();
ffffffffc0201578:	bb3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020157c:	fe0549e3          	bltz	a0,ffffffffc020156e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201580:	fea959e3          	bge	s2,a0,ffffffffc0201572 <readline+0x54>
ffffffffc0201584:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201586:	e42a                	sd	a0,8(sp)
ffffffffc0201588:	b61fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020158c:	6522                	ld	a0,8(sp)
ffffffffc020158e:	009b87b3          	add	a5,s7,s1
ffffffffc0201592:	2485                	addiw	s1,s1,1
ffffffffc0201594:	00a78023          	sb	a0,0(a5)
ffffffffc0201598:	bf7d                	j	ffffffffc0201556 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020159a:	01550463          	beq	a0,s5,ffffffffc02015a2 <readline+0x84>
ffffffffc020159e:	fb651ce3          	bne	a0,s6,ffffffffc0201556 <readline+0x38>
            cputchar(c);
ffffffffc02015a2:	b47fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02015a6:	00005517          	auipc	a0,0x5
ffffffffc02015aa:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0206010 <buf>
ffffffffc02015ae:	94aa                	add	s1,s1,a0
ffffffffc02015b0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02015b4:	60a6                	ld	ra,72(sp)
ffffffffc02015b6:	6486                	ld	s1,64(sp)
ffffffffc02015b8:	7962                	ld	s2,56(sp)
ffffffffc02015ba:	79c2                	ld	s3,48(sp)
ffffffffc02015bc:	7a22                	ld	s4,40(sp)
ffffffffc02015be:	7a82                	ld	s5,32(sp)
ffffffffc02015c0:	6b62                	ld	s6,24(sp)
ffffffffc02015c2:	6bc2                	ld	s7,16(sp)
ffffffffc02015c4:	6161                	addi	sp,sp,80
ffffffffc02015c6:	8082                	ret
            cputchar(c);
ffffffffc02015c8:	4521                	li	a0,8
ffffffffc02015ca:	b1ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02015ce:	34fd                	addiw	s1,s1,-1
ffffffffc02015d0:	b759                	j	ffffffffc0201556 <readline+0x38>

ffffffffc02015d2 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02015d2:	4781                	li	a5,0
ffffffffc02015d4:	00005717          	auipc	a4,0x5
ffffffffc02015d8:	a3473703          	ld	a4,-1484(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02015dc:	88ba                	mv	a7,a4
ffffffffc02015de:	852a                	mv	a0,a0
ffffffffc02015e0:	85be                	mv	a1,a5
ffffffffc02015e2:	863e                	mv	a2,a5
ffffffffc02015e4:	00000073          	ecall
ffffffffc02015e8:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02015ea:	8082                	ret

ffffffffc02015ec <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02015ec:	4781                	li	a5,0
ffffffffc02015ee:	00005717          	auipc	a4,0x5
ffffffffc02015f2:	e8273703          	ld	a4,-382(a4) # ffffffffc0206470 <SBI_SET_TIMER>
ffffffffc02015f6:	88ba                	mv	a7,a4
ffffffffc02015f8:	852a                	mv	a0,a0
ffffffffc02015fa:	85be                	mv	a1,a5
ffffffffc02015fc:	863e                	mv	a2,a5
ffffffffc02015fe:	00000073          	ecall
ffffffffc0201602:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201604:	8082                	ret

ffffffffc0201606 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201606:	4501                	li	a0,0
ffffffffc0201608:	00005797          	auipc	a5,0x5
ffffffffc020160c:	9f87b783          	ld	a5,-1544(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201610:	88be                	mv	a7,a5
ffffffffc0201612:	852a                	mv	a0,a0
ffffffffc0201614:	85aa                	mv	a1,a0
ffffffffc0201616:	862a                	mv	a2,a0
ffffffffc0201618:	00000073          	ecall
ffffffffc020161c:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020161e:	2501                	sext.w	a0,a0
ffffffffc0201620:	8082                	ret

ffffffffc0201622 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201622:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201624:	e589                	bnez	a1,ffffffffc020162e <strnlen+0xc>
ffffffffc0201626:	a811                	j	ffffffffc020163a <strnlen+0x18>
        cnt ++;
ffffffffc0201628:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020162a:	00f58863          	beq	a1,a5,ffffffffc020163a <strnlen+0x18>
ffffffffc020162e:	00f50733          	add	a4,a0,a5
ffffffffc0201632:	00074703          	lbu	a4,0(a4)
ffffffffc0201636:	fb6d                	bnez	a4,ffffffffc0201628 <strnlen+0x6>
ffffffffc0201638:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020163a:	852e                	mv	a0,a1
ffffffffc020163c:	8082                	ret

ffffffffc020163e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020163e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201642:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201646:	cb89                	beqz	a5,ffffffffc0201658 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201648:	0505                	addi	a0,a0,1
ffffffffc020164a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020164c:	fee789e3          	beq	a5,a4,ffffffffc020163e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201650:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201654:	9d19                	subw	a0,a0,a4
ffffffffc0201656:	8082                	ret
ffffffffc0201658:	4501                	li	a0,0
ffffffffc020165a:	bfed                	j	ffffffffc0201654 <strcmp+0x16>

ffffffffc020165c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020165c:	00054783          	lbu	a5,0(a0)
ffffffffc0201660:	c799                	beqz	a5,ffffffffc020166e <strchr+0x12>
        if (*s == c) {
ffffffffc0201662:	00f58763          	beq	a1,a5,ffffffffc0201670 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201666:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020166a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020166c:	fbfd                	bnez	a5,ffffffffc0201662 <strchr+0x6>
    }
    return NULL;
ffffffffc020166e:	4501                	li	a0,0
}
ffffffffc0201670:	8082                	ret

ffffffffc0201672 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201672:	ca01                	beqz	a2,ffffffffc0201682 <memset+0x10>
ffffffffc0201674:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201676:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201678:	0785                	addi	a5,a5,1
ffffffffc020167a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020167e:	fec79de3          	bne	a5,a2,ffffffffc0201678 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201682:	8082                	ret
