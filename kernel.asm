
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 80 c6 10 80       	mov    $0x8010c680,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 25 35 10 80       	mov    $0x80103525,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 48 88 10 	movl   $0x80108848,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100049:	e8 ae 4f 00 00       	call   80104ffc <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 b0 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb0
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 b4 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb4
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801000bd:	e8 5b 4f 00 00       	call   8010501d <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	83 c8 01             	or     $0x1,%eax
801000f6:	89 c2                	mov    %eax,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100104:	e8 76 4f 00 00       	call   8010507f <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 c6 10 	movl   $0x8010c680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 77 48 00 00       	call   8010499b <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 b0 db 10 80       	mov    0x8010dbb0,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010017c:	e8 fe 4e 00 00       	call   8010507f <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 4f 88 10 80 	movl   $0x8010884f,(%esp)
8010019f:	e8 96 03 00 00       	call   8010053a <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 29 27 00 00       	call   80102901 <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 60 88 10 80 	movl   $0x80108860,(%esp)
801001f6:	e8 3f 03 00 00       	call   8010053a <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	83 c8 04             	or     $0x4,%eax
80100203:	89 c2                	mov    %eax,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 ec 26 00 00       	call   80102901 <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 67 88 10 80 	movl   $0x80108867,(%esp)
80100230:	e8 05 03 00 00       	call   8010053a <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010023c:	e8 dc 4d 00 00       	call   8010501d <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	83 e0 fe             	and    $0xfffffffe,%eax
80100290:	89 c2                	mov    %eax,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 d5 47 00 00       	call   80104a77 <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801002a9:	e8 d1 4d 00 00       	call   8010507f <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	83 ec 14             	sub    $0x14,%esp
801002b6:	8b 45 08             	mov    0x8(%ebp),%eax
801002b9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002bd:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	ec                   	in     (%dx),%al
801002c4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002c7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002cb:	c9                   	leave  
801002cc:	c3                   	ret    

801002cd <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002cd:	55                   	push   %ebp
801002ce:	89 e5                	mov    %esp,%ebp
801002d0:	83 ec 08             	sub    $0x8,%esp
801002d3:	8b 55 08             	mov    0x8(%ebp),%edx
801002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801002d9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801002dd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002e0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801002e4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801002e8:	ee                   	out    %al,(%dx)
}
801002e9:	c9                   	leave  
801002ea:	c3                   	ret    

801002eb <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002eb:	55                   	push   %ebp
801002ec:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002ee:	fa                   	cli    
}
801002ef:	5d                   	pop    %ebp
801002f0:	c3                   	ret    

801002f1 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	56                   	push   %esi
801002f5:	53                   	push   %ebx
801002f6:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
801002f9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801002fd:	74 1c                	je     8010031b <printint+0x2a>
801002ff:	8b 45 08             	mov    0x8(%ebp),%eax
80100302:	c1 e8 1f             	shr    $0x1f,%eax
80100305:	0f b6 c0             	movzbl %al,%eax
80100308:	89 45 10             	mov    %eax,0x10(%ebp)
8010030b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010030f:	74 0a                	je     8010031b <printint+0x2a>
    x = -xx;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	f7 d8                	neg    %eax
80100316:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100319:	eb 06                	jmp    80100321 <printint+0x30>
  else
    x = xx;
8010031b:	8b 45 08             	mov    0x8(%ebp),%eax
8010031e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100321:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100328:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010032b:	8d 41 01             	lea    0x1(%ecx),%eax
8010032e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100334:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100337:	ba 00 00 00 00       	mov    $0x0,%edx
8010033c:	f7 f3                	div    %ebx
8010033e:	89 d0                	mov    %edx,%eax
80100340:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
80100347:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010034b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010034e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100351:	ba 00 00 00 00       	mov    $0x0,%edx
80100356:	f7 f6                	div    %esi
80100358:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010035b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010035f:	75 c7                	jne    80100328 <printint+0x37>

  if(sign)
80100361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100365:	74 10                	je     80100377 <printint+0x86>
    buf[i++] = '-';
80100367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010036a:	8d 50 01             	lea    0x1(%eax),%edx
8010036d:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100370:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100375:	eb 18                	jmp    8010038f <printint+0x9e>
80100377:	eb 16                	jmp    8010038f <printint+0x9e>
    consputc(buf[i]);
80100379:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010037c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010037f:	01 d0                	add    %edx,%eax
80100381:	0f b6 00             	movzbl (%eax),%eax
80100384:	0f be c0             	movsbl %al,%eax
80100387:	89 04 24             	mov    %eax,(%esp)
8010038a:	e8 c1 03 00 00       	call   80100750 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
8010038f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100393:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100397:	79 e0                	jns    80100379 <printint+0x88>
    consputc(buf[i]);
}
80100399:	83 c4 30             	add    $0x30,%esp
8010039c:	5b                   	pop    %ebx
8010039d:	5e                   	pop    %esi
8010039e:	5d                   	pop    %ebp
8010039f:	c3                   	ret    

801003a0 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a0:	55                   	push   %ebp
801003a1:	89 e5                	mov    %esp,%ebp
801003a3:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a6:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ab:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b2:	74 0c                	je     801003c0 <cprintf+0x20>
    acquire(&cons.lock);
801003b4:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801003bb:	e8 5d 4c 00 00       	call   8010501d <acquire>

  if (fmt == 0)
801003c0:	8b 45 08             	mov    0x8(%ebp),%eax
801003c3:	85 c0                	test   %eax,%eax
801003c5:	75 0c                	jne    801003d3 <cprintf+0x33>
    panic("null fmt");
801003c7:	c7 04 24 6e 88 10 80 	movl   $0x8010886e,(%esp)
801003ce:	e8 67 01 00 00       	call   8010053a <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d3:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e0:	e9 21 01 00 00       	jmp    80100506 <cprintf+0x166>
    if(c != '%'){
801003e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003e9:	74 10                	je     801003fb <cprintf+0x5b>
      consputc(c);
801003eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ee:	89 04 24             	mov    %eax,(%esp)
801003f1:	e8 5a 03 00 00       	call   80100750 <consputc>
      continue;
801003f6:	e9 07 01 00 00       	jmp    80100502 <cprintf+0x162>
    }
    c = fmt[++i] & 0xff;
801003fb:	8b 55 08             	mov    0x8(%ebp),%edx
801003fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	0f b6 00             	movzbl (%eax),%eax
8010040a:	0f be c0             	movsbl %al,%eax
8010040d:	25 ff 00 00 00       	and    $0xff,%eax
80100412:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100419:	75 05                	jne    80100420 <cprintf+0x80>
      break;
8010041b:	e9 06 01 00 00       	jmp    80100526 <cprintf+0x186>
    switch(c){
80100420:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100423:	83 f8 70             	cmp    $0x70,%eax
80100426:	74 4f                	je     80100477 <cprintf+0xd7>
80100428:	83 f8 70             	cmp    $0x70,%eax
8010042b:	7f 13                	jg     80100440 <cprintf+0xa0>
8010042d:	83 f8 25             	cmp    $0x25,%eax
80100430:	0f 84 a6 00 00 00    	je     801004dc <cprintf+0x13c>
80100436:	83 f8 64             	cmp    $0x64,%eax
80100439:	74 14                	je     8010044f <cprintf+0xaf>
8010043b:	e9 aa 00 00 00       	jmp    801004ea <cprintf+0x14a>
80100440:	83 f8 73             	cmp    $0x73,%eax
80100443:	74 57                	je     8010049c <cprintf+0xfc>
80100445:	83 f8 78             	cmp    $0x78,%eax
80100448:	74 2d                	je     80100477 <cprintf+0xd7>
8010044a:	e9 9b 00 00 00       	jmp    801004ea <cprintf+0x14a>
    case 'd':
      printint(*argp++, 10, 1);
8010044f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100452:	8d 50 04             	lea    0x4(%eax),%edx
80100455:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100458:	8b 00                	mov    (%eax),%eax
8010045a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100461:	00 
80100462:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100469:	00 
8010046a:	89 04 24             	mov    %eax,(%esp)
8010046d:	e8 7f fe ff ff       	call   801002f1 <printint>
      break;
80100472:	e9 8b 00 00 00       	jmp    80100502 <cprintf+0x162>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047a:	8d 50 04             	lea    0x4(%eax),%edx
8010047d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100480:	8b 00                	mov    (%eax),%eax
80100482:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100489:	00 
8010048a:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80100491:	00 
80100492:	89 04 24             	mov    %eax,(%esp)
80100495:	e8 57 fe ff ff       	call   801002f1 <printint>
      break;
8010049a:	eb 66                	jmp    80100502 <cprintf+0x162>
    case 's':
      if((s = (char*)*argp++) == 0)
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004ae:	75 09                	jne    801004b9 <cprintf+0x119>
        s = "(null)";
801004b0:	c7 45 ec 77 88 10 80 	movl   $0x80108877,-0x14(%ebp)
      for(; *s; s++)
801004b7:	eb 17                	jmp    801004d0 <cprintf+0x130>
801004b9:	eb 15                	jmp    801004d0 <cprintf+0x130>
        consputc(*s);
801004bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004be:	0f b6 00             	movzbl (%eax),%eax
801004c1:	0f be c0             	movsbl %al,%eax
801004c4:	89 04 24             	mov    %eax,(%esp)
801004c7:	e8 84 02 00 00       	call   80100750 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004cc:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d3:	0f b6 00             	movzbl (%eax),%eax
801004d6:	84 c0                	test   %al,%al
801004d8:	75 e1                	jne    801004bb <cprintf+0x11b>
        consputc(*s);
      break;
801004da:	eb 26                	jmp    80100502 <cprintf+0x162>
    case '%':
      consputc('%');
801004dc:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004e3:	e8 68 02 00 00       	call   80100750 <consputc>
      break;
801004e8:	eb 18                	jmp    80100502 <cprintf+0x162>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004ea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004f1:	e8 5a 02 00 00       	call   80100750 <consputc>
      consputc(c);
801004f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f9:	89 04 24             	mov    %eax,(%esp)
801004fc:	e8 4f 02 00 00       	call   80100750 <consputc>
      break;
80100501:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100502:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100506:	8b 55 08             	mov    0x8(%ebp),%edx
80100509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010050c:	01 d0                	add    %edx,%eax
8010050e:	0f b6 00             	movzbl (%eax),%eax
80100511:	0f be c0             	movsbl %al,%eax
80100514:	25 ff 00 00 00       	and    $0xff,%eax
80100519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010051c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100520:	0f 85 bf fe ff ff    	jne    801003e5 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100526:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010052a:	74 0c                	je     80100538 <cprintf+0x198>
    release(&cons.lock);
8010052c:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100533:	e8 47 4b 00 00       	call   8010507f <release>
}
80100538:	c9                   	leave  
80100539:	c3                   	ret    

8010053a <panic>:

void
panic(char *s)
{
8010053a:	55                   	push   %ebp
8010053b:	89 e5                	mov    %esp,%ebp
8010053d:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
80100540:	e8 a6 fd ff ff       	call   801002eb <cli>
  cons.locking = 0;
80100545:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
8010054c:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100555:	0f b6 00             	movzbl (%eax),%eax
80100558:	0f b6 c0             	movzbl %al,%eax
8010055b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055f:	c7 04 24 7e 88 10 80 	movl   $0x8010887e,(%esp)
80100566:	e8 35 fe ff ff       	call   801003a0 <cprintf>
  cprintf(s);
8010056b:	8b 45 08             	mov    0x8(%ebp),%eax
8010056e:	89 04 24             	mov    %eax,(%esp)
80100571:	e8 2a fe ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
80100576:	c7 04 24 8d 88 10 80 	movl   $0x8010888d,(%esp)
8010057d:	e8 1e fe ff ff       	call   801003a0 <cprintf>
  getcallerpcs(&s, pcs);
80100582:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100585:	89 44 24 04          	mov    %eax,0x4(%esp)
80100589:	8d 45 08             	lea    0x8(%ebp),%eax
8010058c:	89 04 24             	mov    %eax,(%esp)
8010058f:	e8 3a 4b 00 00       	call   801050ce <getcallerpcs>
  for(i=0; i<10; i++)
80100594:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010059b:	eb 1b                	jmp    801005b8 <panic+0x7e>
    cprintf(" %p", pcs[i]);
8010059d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005a0:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a8:	c7 04 24 8f 88 10 80 	movl   $0x8010888f,(%esp)
801005af:	e8 ec fd ff ff       	call   801003a0 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005b8:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005bc:	7e df                	jle    8010059d <panic+0x63>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005be:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005c5:	00 00 00 
  for(;;)
    ;
801005c8:	eb fe                	jmp    801005c8 <panic+0x8e>

801005ca <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005ca:	55                   	push   %ebp
801005cb:	89 e5                	mov    %esp,%ebp
801005cd:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005d0:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d7:	00 
801005d8:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005df:	e8 e9 fc ff ff       	call   801002cd <outb>
  pos = inb(CRTPORT+1) << 8;
801005e4:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005eb:	e8 c0 fc ff ff       	call   801002b0 <inb>
801005f0:	0f b6 c0             	movzbl %al,%eax
801005f3:	c1 e0 08             	shl    $0x8,%eax
801005f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100600:	00 
80100601:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100608:	e8 c0 fc ff ff       	call   801002cd <outb>
  pos |= inb(CRTPORT+1);
8010060d:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100614:	e8 97 fc ff ff       	call   801002b0 <inb>
80100619:	0f b6 c0             	movzbl %al,%eax
8010061c:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010061f:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100623:	75 30                	jne    80100655 <cgaputc+0x8b>
    pos += 80 - pos%80;
80100625:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100628:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010062d:	89 c8                	mov    %ecx,%eax
8010062f:	f7 ea                	imul   %edx
80100631:	c1 fa 05             	sar    $0x5,%edx
80100634:	89 c8                	mov    %ecx,%eax
80100636:	c1 f8 1f             	sar    $0x1f,%eax
80100639:	29 c2                	sub    %eax,%edx
8010063b:	89 d0                	mov    %edx,%eax
8010063d:	c1 e0 02             	shl    $0x2,%eax
80100640:	01 d0                	add    %edx,%eax
80100642:	c1 e0 04             	shl    $0x4,%eax
80100645:	29 c1                	sub    %eax,%ecx
80100647:	89 ca                	mov    %ecx,%edx
80100649:	b8 50 00 00 00       	mov    $0x50,%eax
8010064e:	29 d0                	sub    %edx,%eax
80100650:	01 45 f4             	add    %eax,-0xc(%ebp)
80100653:	eb 35                	jmp    8010068a <cgaputc+0xc0>
  else if(c == BACKSPACE){
80100655:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010065c:	75 0c                	jne    8010066a <cgaputc+0xa0>
    if(pos > 0) --pos;
8010065e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100662:	7e 26                	jle    8010068a <cgaputc+0xc0>
80100664:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100668:	eb 20                	jmp    8010068a <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010066a:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100670:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100673:	8d 50 01             	lea    0x1(%eax),%edx
80100676:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100679:	01 c0                	add    %eax,%eax
8010067b:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067e:	8b 45 08             	mov    0x8(%ebp),%eax
80100681:	0f b6 c0             	movzbl %al,%eax
80100684:	80 cc 07             	or     $0x7,%ah
80100687:	66 89 02             	mov    %ax,(%edx)
  
  if((pos/80) >= 24){  // Scroll up.
8010068a:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100691:	7e 53                	jle    801006e6 <cgaputc+0x11c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100693:	a1 00 90 10 80       	mov    0x80109000,%eax
80100698:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
8010069e:	a1 00 90 10 80       	mov    0x80109000,%eax
801006a3:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006aa:	00 
801006ab:	89 54 24 04          	mov    %edx,0x4(%esp)
801006af:	89 04 24             	mov    %eax,(%esp)
801006b2:	e8 89 4c 00 00       	call   80105340 <memmove>
    pos -= 80;
801006b7:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006bb:	b8 80 07 00 00       	mov    $0x780,%eax
801006c0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006c3:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006c6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006cb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006ce:	01 c9                	add    %ecx,%ecx
801006d0:	01 c8                	add    %ecx,%eax
801006d2:	89 54 24 08          	mov    %edx,0x8(%esp)
801006d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006dd:	00 
801006de:	89 04 24             	mov    %eax,(%esp)
801006e1:	e8 8b 4b 00 00       	call   80105271 <memset>
  }
  
  outb(CRTPORT, 14);
801006e6:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006ed:	00 
801006ee:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006f5:	e8 d3 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos>>8);
801006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006fd:	c1 f8 08             	sar    $0x8,%eax
80100700:	0f b6 c0             	movzbl %al,%eax
80100703:	89 44 24 04          	mov    %eax,0x4(%esp)
80100707:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010070e:	e8 ba fb ff ff       	call   801002cd <outb>
  outb(CRTPORT, 15);
80100713:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
8010071a:	00 
8010071b:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100722:	e8 a6 fb ff ff       	call   801002cd <outb>
  outb(CRTPORT+1, pos);
80100727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010072a:	0f b6 c0             	movzbl %al,%eax
8010072d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100731:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100738:	e8 90 fb ff ff       	call   801002cd <outb>
  crt[pos] = ' ' | 0x0700;
8010073d:	a1 00 90 10 80       	mov    0x80109000,%eax
80100742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100745:	01 d2                	add    %edx,%edx
80100747:	01 d0                	add    %edx,%eax
80100749:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010074e:	c9                   	leave  
8010074f:	c3                   	ret    

80100750 <consputc>:

void
consputc(int c)
{
80100750:	55                   	push   %ebp
80100751:	89 e5                	mov    %esp,%ebp
80100753:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100756:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
8010075b:	85 c0                	test   %eax,%eax
8010075d:	74 07                	je     80100766 <consputc+0x16>
    cli();
8010075f:	e8 87 fb ff ff       	call   801002eb <cli>
    for(;;)
      ;
80100764:	eb fe                	jmp    80100764 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100766:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010076d:	75 26                	jne    80100795 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010076f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100776:	e8 0d 67 00 00       	call   80106e88 <uartputc>
8010077b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100782:	e8 01 67 00 00       	call   80106e88 <uartputc>
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 f5 66 00 00       	call   80106e88 <uartputc>
80100793:	eb 0b                	jmp    801007a0 <consputc+0x50>
  } else
    uartputc(c);
80100795:	8b 45 08             	mov    0x8(%ebp),%eax
80100798:	89 04 24             	mov    %eax,(%esp)
8010079b:	e8 e8 66 00 00       	call   80106e88 <uartputc>
  cgaputc(c);
801007a0:	8b 45 08             	mov    0x8(%ebp),%eax
801007a3:	89 04 24             	mov    %eax,(%esp)
801007a6:	e8 1f fe ff ff       	call   801005ca <cgaputc>
}
801007ab:	c9                   	leave  
801007ac:	c3                   	ret    

801007ad <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ad:	55                   	push   %ebp
801007ae:	89 e5                	mov    %esp,%ebp
801007b0:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
801007b3:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
801007ba:	e8 5e 48 00 00       	call   8010501d <acquire>
  while((c = getc()) >= 0){
801007bf:	e9 37 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    switch(c){
801007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007c7:	83 f8 10             	cmp    $0x10,%eax
801007ca:	74 1e                	je     801007ea <consoleintr+0x3d>
801007cc:	83 f8 10             	cmp    $0x10,%eax
801007cf:	7f 0a                	jg     801007db <consoleintr+0x2e>
801007d1:	83 f8 08             	cmp    $0x8,%eax
801007d4:	74 64                	je     8010083a <consoleintr+0x8d>
801007d6:	e9 91 00 00 00       	jmp    8010086c <consoleintr+0xbf>
801007db:	83 f8 15             	cmp    $0x15,%eax
801007de:	74 2f                	je     8010080f <consoleintr+0x62>
801007e0:	83 f8 7f             	cmp    $0x7f,%eax
801007e3:	74 55                	je     8010083a <consoleintr+0x8d>
801007e5:	e9 82 00 00 00       	jmp    8010086c <consoleintr+0xbf>
    case C('P'):  // Process listing.
      procdump();
801007ea:	e8 2e 43 00 00       	call   80104b1d <procdump>
      break;
801007ef:	e9 07 01 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007f4:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801007f9:	83 e8 01             	sub    $0x1,%eax
801007fc:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100801:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
80100808:	e8 43 ff ff ff       	call   80100750 <consputc>
8010080d:	eb 01                	jmp    80100810 <consoleintr+0x63>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080f:	90                   	nop
80100810:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
80100816:	a1 78 de 10 80       	mov    0x8010de78,%eax
8010081b:	39 c2                	cmp    %eax,%edx
8010081d:	74 16                	je     80100835 <consoleintr+0x88>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010081f:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100824:	83 e8 01             	sub    $0x1,%eax
80100827:	83 e0 7f             	and    $0x7f,%eax
8010082a:	0f b6 80 f4 dd 10 80 	movzbl -0x7fef220c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100831:	3c 0a                	cmp    $0xa,%al
80100833:	75 bf                	jne    801007f4 <consoleintr+0x47>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100835:	e9 c1 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010083a:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
80100840:	a1 78 de 10 80       	mov    0x8010de78,%eax
80100845:	39 c2                	cmp    %eax,%edx
80100847:	74 1e                	je     80100867 <consoleintr+0xba>
        input.e--;
80100849:	a1 7c de 10 80       	mov    0x8010de7c,%eax
8010084e:	83 e8 01             	sub    $0x1,%eax
80100851:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100856:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010085d:	e8 ee fe ff ff       	call   80100750 <consputc>
      }
      break;
80100862:	e9 94 00 00 00       	jmp    801008fb <consoleintr+0x14e>
80100867:	e9 8f 00 00 00       	jmp    801008fb <consoleintr+0x14e>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010086c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100870:	0f 84 84 00 00 00    	je     801008fa <consoleintr+0x14d>
80100876:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
8010087c:	a1 74 de 10 80       	mov    0x8010de74,%eax
80100881:	29 c2                	sub    %eax,%edx
80100883:	89 d0                	mov    %edx,%eax
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	77 70                	ja     801008fa <consoleintr+0x14d>
        c = (c == '\r') ? '\n' : c;
8010088a:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010088e:	74 05                	je     80100895 <consoleintr+0xe8>
80100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100893:	eb 05                	jmp    8010089a <consoleintr+0xed>
80100895:	b8 0a 00 00 00       	mov    $0xa,%eax
8010089a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010089d:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008a2:	8d 50 01             	lea    0x1(%eax),%edx
801008a5:	89 15 7c de 10 80    	mov    %edx,0x8010de7c
801008ab:	83 e0 7f             	and    $0x7f,%eax
801008ae:	89 c2                	mov    %eax,%edx
801008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008b3:	88 82 f4 dd 10 80    	mov    %al,-0x7fef220c(%edx)
        consputc(c);
801008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008bc:	89 04 24             	mov    %eax,(%esp)
801008bf:	e8 8c fe ff ff       	call   80100750 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801008c4:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008c8:	74 18                	je     801008e2 <consoleintr+0x135>
801008ca:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008ce:	74 12                	je     801008e2 <consoleintr+0x135>
801008d0:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008d5:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
801008db:	83 ea 80             	sub    $0xffffff80,%edx
801008de:	39 d0                	cmp    %edx,%eax
801008e0:	75 18                	jne    801008fa <consoleintr+0x14d>
          input.w = input.e;
801008e2:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008e7:	a3 78 de 10 80       	mov    %eax,0x8010de78
          wakeup(&input.r);
801008ec:	c7 04 24 74 de 10 80 	movl   $0x8010de74,(%esp)
801008f3:	e8 7f 41 00 00       	call   80104a77 <wakeup>
        }
      }
      break;
801008f8:	eb 00                	jmp    801008fa <consoleintr+0x14d>
801008fa:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008fb:	8b 45 08             	mov    0x8(%ebp),%eax
801008fe:	ff d0                	call   *%eax
80100900:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100903:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100907:	0f 89 b7 fe ff ff    	jns    801007c4 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010090d:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100914:	e8 66 47 00 00       	call   8010507f <release>
}
80100919:	c9                   	leave  
8010091a:	c3                   	ret    

8010091b <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010091b:	55                   	push   %ebp
8010091c:	89 e5                	mov    %esp,%ebp
8010091e:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100921:	8b 45 08             	mov    0x8(%ebp),%eax
80100924:	89 04 24             	mov    %eax,(%esp)
80100927:	e8 69 10 00 00       	call   80101995 <iunlock>
  target = n;
8010092c:	8b 45 10             	mov    0x10(%ebp),%eax
8010092f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100932:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100939:	e8 df 46 00 00       	call   8010501d <acquire>
  while(n > 0){
8010093e:	e9 aa 00 00 00       	jmp    801009ed <consoleread+0xd2>
    while(input.r == input.w){
80100943:	eb 42                	jmp    80100987 <consoleread+0x6c>
      if(proc->killed){
80100945:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010094b:	8b 40 24             	mov    0x24(%eax),%eax
8010094e:	85 c0                	test   %eax,%eax
80100950:	74 21                	je     80100973 <consoleread+0x58>
        release(&input.lock);
80100952:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100959:	e8 21 47 00 00       	call   8010507f <release>
        ilock(ip);
8010095e:	8b 45 08             	mov    0x8(%ebp),%eax
80100961:	89 04 24             	mov    %eax,(%esp)
80100964:	e8 de 0e 00 00       	call   80101847 <ilock>
        return -1;
80100969:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010096e:	e9 a5 00 00 00       	jmp    80100a18 <consoleread+0xfd>
      }
      sleep(&input.r, &input.lock);
80100973:	c7 44 24 04 c0 dd 10 	movl   $0x8010ddc0,0x4(%esp)
8010097a:	80 
8010097b:	c7 04 24 74 de 10 80 	movl   $0x8010de74,(%esp)
80100982:	e8 14 40 00 00       	call   8010499b <sleep>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100987:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
8010098d:	a1 78 de 10 80       	mov    0x8010de78,%eax
80100992:	39 c2                	cmp    %eax,%edx
80100994:	74 af                	je     80100945 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100996:	a1 74 de 10 80       	mov    0x8010de74,%eax
8010099b:	8d 50 01             	lea    0x1(%eax),%edx
8010099e:	89 15 74 de 10 80    	mov    %edx,0x8010de74
801009a4:	83 e0 7f             	and    $0x7f,%eax
801009a7:	0f b6 80 f4 dd 10 80 	movzbl -0x7fef220c(%eax),%eax
801009ae:	0f be c0             	movsbl %al,%eax
801009b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
801009b4:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
801009b8:	75 19                	jne    801009d3 <consoleread+0xb8>
      if(n < target){
801009ba:	8b 45 10             	mov    0x10(%ebp),%eax
801009bd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009c0:	73 0f                	jae    801009d1 <consoleread+0xb6>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009c2:	a1 74 de 10 80       	mov    0x8010de74,%eax
801009c7:	83 e8 01             	sub    $0x1,%eax
801009ca:	a3 74 de 10 80       	mov    %eax,0x8010de74
      }
      break;
801009cf:	eb 26                	jmp    801009f7 <consoleread+0xdc>
801009d1:	eb 24                	jmp    801009f7 <consoleread+0xdc>
    }
    *dst++ = c;
801009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801009d6:	8d 50 01             	lea    0x1(%eax),%edx
801009d9:	89 55 0c             	mov    %edx,0xc(%ebp)
801009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801009df:	88 10                	mov    %dl,(%eax)
    --n;
801009e1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
801009e5:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009e9:	75 02                	jne    801009ed <consoleread+0xd2>
      break;
801009eb:	eb 0a                	jmp    801009f7 <consoleread+0xdc>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009ed:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009f1:	0f 8f 4c ff ff ff    	jg     80100943 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&input.lock);
801009f7:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
801009fe:	e8 7c 46 00 00       	call   8010507f <release>
  ilock(ip);
80100a03:	8b 45 08             	mov    0x8(%ebp),%eax
80100a06:	89 04 24             	mov    %eax,(%esp)
80100a09:	e8 39 0e 00 00       	call   80101847 <ilock>

  return target - n;
80100a0e:	8b 45 10             	mov    0x10(%ebp),%eax
80100a11:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a14:	29 c2                	sub    %eax,%edx
80100a16:	89 d0                	mov    %edx,%eax
}
80100a18:	c9                   	leave  
80100a19:	c3                   	ret    

80100a1a <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a1a:	55                   	push   %ebp
80100a1b:	89 e5                	mov    %esp,%ebp
80100a1d:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
80100a20:	8b 45 08             	mov    0x8(%ebp),%eax
80100a23:	89 04 24             	mov    %eax,(%esp)
80100a26:	e8 6a 0f 00 00       	call   80101995 <iunlock>
  acquire(&cons.lock);
80100a2b:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a32:	e8 e6 45 00 00       	call   8010501d <acquire>
  for(i = 0; i < n; i++)
80100a37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a3e:	eb 1d                	jmp    80100a5d <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a40:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a46:	01 d0                	add    %edx,%eax
80100a48:	0f b6 00             	movzbl (%eax),%eax
80100a4b:	0f be c0             	movsbl %al,%eax
80100a4e:	0f b6 c0             	movzbl %al,%eax
80100a51:	89 04 24             	mov    %eax,(%esp)
80100a54:	e8 f7 fc ff ff       	call   80100750 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a60:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a63:	7c db                	jl     80100a40 <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a65:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a6c:	e8 0e 46 00 00       	call   8010507f <release>
  ilock(ip);
80100a71:	8b 45 08             	mov    0x8(%ebp),%eax
80100a74:	89 04 24             	mov    %eax,(%esp)
80100a77:	e8 cb 0d 00 00       	call   80101847 <ilock>

  return n;
80100a7c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a7f:	c9                   	leave  
80100a80:	c3                   	ret    

80100a81 <consoleinit>:

void
consoleinit(void)
{
80100a81:	55                   	push   %ebp
80100a82:	89 e5                	mov    %esp,%ebp
80100a84:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a87:	c7 44 24 04 93 88 10 	movl   $0x80108893,0x4(%esp)
80100a8e:	80 
80100a8f:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a96:	e8 61 45 00 00       	call   80104ffc <initlock>
  initlock(&input.lock, "input");
80100a9b:	c7 44 24 04 9b 88 10 	movl   $0x8010889b,0x4(%esp)
80100aa2:	80 
80100aa3:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100aaa:	e8 4d 45 00 00       	call   80104ffc <initlock>

  devsw[CONSOLE].write = consolewrite;
80100aaf:	c7 05 2c e8 10 80 1a 	movl   $0x80100a1a,0x8010e82c
80100ab6:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ab9:	c7 05 28 e8 10 80 1b 	movl   $0x8010091b,0x8010e828
80100ac0:	09 10 80 
  cons.locking = 1;
80100ac3:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100aca:	00 00 00 

  picenable(IRQ_KBD);
80100acd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ad4:	e8 e9 30 00 00       	call   80103bc2 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ad9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100ae0:	00 
80100ae1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ae8:	e8 d0 1f 00 00       	call   80102abd <ioapicenable>
}
80100aed:	c9                   	leave  
80100aee:	c3                   	ret    

80100aef <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100aef:	55                   	push   %ebp
80100af0:	89 e5                	mov    %esp,%ebp
80100af2:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100af8:	8b 45 08             	mov    0x8(%ebp),%eax
80100afb:	89 04 24             	mov    %eax,(%esp)
80100afe:	e8 63 1a 00 00       	call   80102566 <namei>
80100b03:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b06:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b0a:	75 0a                	jne    80100b16 <exec+0x27>
    return -1;
80100b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b11:	e9 de 03 00 00       	jmp    80100ef4 <exec+0x405>
  ilock(ip);
80100b16:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b19:	89 04 24             	mov    %eax,(%esp)
80100b1c:	e8 26 0d 00 00       	call   80101847 <ilock>
  pgdir = 0;
80100b21:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b28:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b2f:	00 
80100b30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b37:	00 
80100b38:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b42:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b45:	89 04 24             	mov    %eax,(%esp)
80100b48:	e8 7b 13 00 00       	call   80101ec8 <readi>
80100b4d:	83 f8 33             	cmp    $0x33,%eax
80100b50:	77 05                	ja     80100b57 <exec+0x68>
    goto bad;
80100b52:	e9 76 03 00 00       	jmp    80100ecd <exec+0x3de>
  if(elf.magic != ELF_MAGIC)
80100b57:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b5d:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b62:	74 05                	je     80100b69 <exec+0x7a>
    goto bad;
80100b64:	e9 64 03 00 00       	jmp    80100ecd <exec+0x3de>

  if((pgdir = setupkvm()) == 0)
80100b69:	e8 6b 74 00 00       	call   80107fd9 <setupkvm>
80100b6e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b71:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b75:	75 05                	jne    80100b7c <exec+0x8d>
    goto bad;
80100b77:	e9 51 03 00 00       	jmp    80100ecd <exec+0x3de>

  // Load program into memory.
  sz = 0;
80100b7c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b83:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b8a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b90:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b93:	e9 cb 00 00 00       	jmp    80100c63 <exec+0x174>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100b98:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b9b:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100ba2:	00 
80100ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ba7:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100bad:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100bb4:	89 04 24             	mov    %eax,(%esp)
80100bb7:	e8 0c 13 00 00       	call   80101ec8 <readi>
80100bbc:	83 f8 20             	cmp    $0x20,%eax
80100bbf:	74 05                	je     80100bc6 <exec+0xd7>
      goto bad;
80100bc1:	e9 07 03 00 00       	jmp    80100ecd <exec+0x3de>
    if(ph.type != ELF_PROG_LOAD)
80100bc6:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100bcc:	83 f8 01             	cmp    $0x1,%eax
80100bcf:	74 05                	je     80100bd6 <exec+0xe7>
      continue;
80100bd1:	e9 80 00 00 00       	jmp    80100c56 <exec+0x167>
    if(ph.memsz < ph.filesz)
80100bd6:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bdc:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100be2:	39 c2                	cmp    %eax,%edx
80100be4:	73 05                	jae    80100beb <exec+0xfc>
      goto bad;
80100be6:	e9 e2 02 00 00       	jmp    80100ecd <exec+0x3de>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100beb:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bf1:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100bf7:	01 d0                	add    %edx,%eax
80100bf9:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c00:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c04:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c07:	89 04 24             	mov    %eax,(%esp)
80100c0a:	e8 98 77 00 00       	call   801083a7 <allocuvm>
80100c0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c12:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c16:	75 05                	jne    80100c1d <exec+0x12e>
      goto bad;
80100c18:	e9 b0 02 00 00       	jmp    80100ecd <exec+0x3de>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c1d:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100c23:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c29:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c2f:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c33:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c37:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c3a:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c45:	89 04 24             	mov    %eax,(%esp)
80100c48:	e8 6f 76 00 00       	call   801082bc <loaduvm>
80100c4d:	85 c0                	test   %eax,%eax
80100c4f:	79 05                	jns    80100c56 <exec+0x167>
      goto bad;
80100c51:	e9 77 02 00 00       	jmp    80100ecd <exec+0x3de>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c56:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c5d:	83 c0 20             	add    $0x20,%eax
80100c60:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c63:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100c6a:	0f b7 c0             	movzwl %ax,%eax
80100c6d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c70:	0f 8f 22 ff ff ff    	jg     80100b98 <exec+0xa9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c76:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c79:	89 04 24             	mov    %eax,(%esp)
80100c7c:	e8 4a 0e 00 00       	call   80101acb <iunlockput>
  ip = 0;
80100c81:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c88:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c8b:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c90:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100c95:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c98:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c9b:	05 00 20 00 00       	add    $0x2000,%eax
80100ca0:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ca4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cae:	89 04 24             	mov    %eax,(%esp)
80100cb1:	e8 f1 76 00 00       	call   801083a7 <allocuvm>
80100cb6:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cb9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cbd:	75 05                	jne    80100cc4 <exec+0x1d5>
    goto bad;
80100cbf:	e9 09 02 00 00       	jmp    80100ecd <exec+0x3de>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100cc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cc7:	2d 00 20 00 00       	sub    $0x2000,%eax
80100ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100cd3:	89 04 24             	mov    %eax,(%esp)
80100cd6:	e8 fc 78 00 00       	call   801085d7 <clearpteu>
  sp = sz;
80100cdb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cde:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ce1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100ce8:	e9 9a 00 00 00       	jmp    80100d87 <exec+0x298>
    if(argc >= MAXARG)
80100ced:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100cf1:	76 05                	jbe    80100cf8 <exec+0x209>
      goto bad;
80100cf3:	e9 d5 01 00 00       	jmp    80100ecd <exec+0x3de>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100cfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d02:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d05:	01 d0                	add    %edx,%eax
80100d07:	8b 00                	mov    (%eax),%eax
80100d09:	89 04 24             	mov    %eax,(%esp)
80100d0c:	e8 ca 47 00 00       	call   801054db <strlen>
80100d11:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100d14:	29 c2                	sub    %eax,%edx
80100d16:	89 d0                	mov    %edx,%eax
80100d18:	83 e8 01             	sub    $0x1,%eax
80100d1b:	83 e0 fc             	and    $0xfffffffc,%eax
80100d1e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d24:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d2e:	01 d0                	add    %edx,%eax
80100d30:	8b 00                	mov    (%eax),%eax
80100d32:	89 04 24             	mov    %eax,(%esp)
80100d35:	e8 a1 47 00 00       	call   801054db <strlen>
80100d3a:	83 c0 01             	add    $0x1,%eax
80100d3d:	89 c2                	mov    %eax,%edx
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4c:	01 c8                	add    %ecx,%eax
80100d4e:	8b 00                	mov    (%eax),%eax
80100d50:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d54:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d5f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d62:	89 04 24             	mov    %eax,(%esp)
80100d65:	e8 32 7a 00 00       	call   8010879c <copyout>
80100d6a:	85 c0                	test   %eax,%eax
80100d6c:	79 05                	jns    80100d73 <exec+0x284>
      goto bad;
80100d6e:	e9 5a 01 00 00       	jmp    80100ecd <exec+0x3de>
    ustack[3+argc] = sp;
80100d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d76:	8d 50 03             	lea    0x3(%eax),%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d83:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	85 c0                	test   %eax,%eax
80100d9a:	0f 85 4d ff ff ff    	jne    80100ced <exec+0x1fe>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da3:	83 c0 03             	add    $0x3,%eax
80100da6:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100dad:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100db1:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100db8:	ff ff ff 
  ustack[1] = argc;
80100dbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbe:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc7:	83 c0 01             	add    $0x1,%eax
80100dca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dd4:	29 d0                	sub    %edx,%eax
80100dd6:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddf:	83 c0 04             	add    $0x4,%eax
80100de2:	c1 e0 02             	shl    $0x2,%eax
80100de5:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100de8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100deb:	83 c0 04             	add    $0x4,%eax
80100dee:	c1 e0 02             	shl    $0x2,%eax
80100df1:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100df5:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100dfb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dff:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e02:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e09:	89 04 24             	mov    %eax,(%esp)
80100e0c:	e8 8b 79 00 00       	call   8010879c <copyout>
80100e11:	85 c0                	test   %eax,%eax
80100e13:	79 05                	jns    80100e1a <exec+0x32b>
    goto bad;
80100e15:	e9 b3 00 00 00       	jmp    80100ecd <exec+0x3de>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80100e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e23:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e26:	eb 17                	jmp    80100e3f <exec+0x350>
    if(*s == '/')
80100e28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e2b:	0f b6 00             	movzbl (%eax),%eax
80100e2e:	3c 2f                	cmp    $0x2f,%al
80100e30:	75 09                	jne    80100e3b <exec+0x34c>
      last = s+1;
80100e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e35:	83 c0 01             	add    $0x1,%eax
80100e38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e3b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e42:	0f b6 00             	movzbl (%eax),%eax
80100e45:	84 c0                	test   %al,%al
80100e47:	75 df                	jne    80100e28 <exec+0x339>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e49:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e4f:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e52:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e59:	00 
80100e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e61:	89 14 24             	mov    %edx,(%esp)
80100e64:	e8 28 46 00 00       	call   80105491 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e6f:	8b 40 04             	mov    0x4(%eax),%eax
80100e72:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e7b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e7e:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e87:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e8a:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e92:	8b 40 18             	mov    0x18(%eax),%eax
80100e95:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e9b:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea4:	8b 40 18             	mov    0x18(%eax),%eax
80100ea7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eaa:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ead:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eb3:	89 04 24             	mov    %eax,(%esp)
80100eb6:	e8 0f 72 00 00       	call   801080ca <switchuvm>
  freevm(oldpgdir);
80100ebb:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ebe:	89 04 24             	mov    %eax,(%esp)
80100ec1:	e8 77 76 00 00       	call   8010853d <freevm>
  return 0;
80100ec6:	b8 00 00 00 00       	mov    $0x0,%eax
80100ecb:	eb 27                	jmp    80100ef4 <exec+0x405>

 bad:
  if(pgdir)
80100ecd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ed1:	74 0b                	je     80100ede <exec+0x3ef>
    freevm(pgdir);
80100ed3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ed6:	89 04 24             	mov    %eax,(%esp)
80100ed9:	e8 5f 76 00 00       	call   8010853d <freevm>
  if(ip)
80100ede:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ee2:	74 0b                	je     80100eef <exec+0x400>
    iunlockput(ip);
80100ee4:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ee7:	89 04 24             	mov    %eax,(%esp)
80100eea:	e8 dc 0b 00 00       	call   80101acb <iunlockput>
  return -1;
80100eef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100ef4:	c9                   	leave  
80100ef5:	c3                   	ret    

80100ef6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100ef6:	55                   	push   %ebp
80100ef7:	89 e5                	mov    %esp,%ebp
80100ef9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100efc:	c7 44 24 04 a1 88 10 	movl   $0x801088a1,0x4(%esp)
80100f03:	80 
80100f04:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f0b:	e8 ec 40 00 00       	call   80104ffc <initlock>
}
80100f10:	c9                   	leave  
80100f11:	c3                   	ret    

80100f12 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f12:	55                   	push   %ebp
80100f13:	89 e5                	mov    %esp,%ebp
80100f15:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f18:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f1f:	e8 f9 40 00 00       	call   8010501d <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f24:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80100f2b:	eb 29                	jmp    80100f56 <filealloc+0x44>
    if(f->ref == 0){
80100f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f30:	8b 40 04             	mov    0x4(%eax),%eax
80100f33:	85 c0                	test   %eax,%eax
80100f35:	75 1b                	jne    80100f52 <filealloc+0x40>
      f->ref = 1;
80100f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f3a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f41:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f48:	e8 32 41 00 00       	call   8010507f <release>
      return f;
80100f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f50:	eb 1e                	jmp    80100f70 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f52:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f56:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
80100f5d:	72 ce                	jb     80100f2d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f5f:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f66:	e8 14 41 00 00       	call   8010507f <release>
  return 0;
80100f6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f70:	c9                   	leave  
80100f71:	c3                   	ret    

80100f72 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f72:	55                   	push   %ebp
80100f73:	89 e5                	mov    %esp,%ebp
80100f75:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f78:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f7f:	e8 99 40 00 00       	call   8010501d <acquire>
  if(f->ref < 1)
80100f84:	8b 45 08             	mov    0x8(%ebp),%eax
80100f87:	8b 40 04             	mov    0x4(%eax),%eax
80100f8a:	85 c0                	test   %eax,%eax
80100f8c:	7f 0c                	jg     80100f9a <filedup+0x28>
    panic("filedup");
80100f8e:	c7 04 24 a8 88 10 80 	movl   $0x801088a8,(%esp)
80100f95:	e8 a0 f5 ff ff       	call   8010053a <panic>
  f->ref++;
80100f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80100f9d:	8b 40 04             	mov    0x4(%eax),%eax
80100fa0:	8d 50 01             	lea    0x1(%eax),%edx
80100fa3:	8b 45 08             	mov    0x8(%ebp),%eax
80100fa6:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100fa9:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100fb0:	e8 ca 40 00 00       	call   8010507f <release>
  return f;
80100fb5:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100fb8:	c9                   	leave  
80100fb9:	c3                   	ret    

80100fba <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fba:	55                   	push   %ebp
80100fbb:	89 e5                	mov    %esp,%ebp
80100fbd:	83 ec 38             	sub    $0x38,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fc0:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100fc7:	e8 51 40 00 00       	call   8010501d <acquire>
  if(f->ref < 1)
80100fcc:	8b 45 08             	mov    0x8(%ebp),%eax
80100fcf:	8b 40 04             	mov    0x4(%eax),%eax
80100fd2:	85 c0                	test   %eax,%eax
80100fd4:	7f 0c                	jg     80100fe2 <fileclose+0x28>
    panic("fileclose");
80100fd6:	c7 04 24 b0 88 10 80 	movl   $0x801088b0,(%esp)
80100fdd:	e8 58 f5 ff ff       	call   8010053a <panic>
  if(--f->ref > 0){
80100fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80100fe5:	8b 40 04             	mov    0x4(%eax),%eax
80100fe8:	8d 50 ff             	lea    -0x1(%eax),%edx
80100feb:	8b 45 08             	mov    0x8(%ebp),%eax
80100fee:	89 50 04             	mov    %edx,0x4(%eax)
80100ff1:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff4:	8b 40 04             	mov    0x4(%eax),%eax
80100ff7:	85 c0                	test   %eax,%eax
80100ff9:	7e 11                	jle    8010100c <fileclose+0x52>
    release(&ftable.lock);
80100ffb:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80101002:	e8 78 40 00 00       	call   8010507f <release>
80101007:	e9 82 00 00 00       	jmp    8010108e <fileclose+0xd4>
    return;
  }
  ff = *f;
8010100c:	8b 45 08             	mov    0x8(%ebp),%eax
8010100f:	8b 10                	mov    (%eax),%edx
80101011:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101014:	8b 50 04             	mov    0x4(%eax),%edx
80101017:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010101a:	8b 50 08             	mov    0x8(%eax),%edx
8010101d:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101020:	8b 50 0c             	mov    0xc(%eax),%edx
80101023:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101026:	8b 50 10             	mov    0x10(%eax),%edx
80101029:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010102c:	8b 40 14             	mov    0x14(%eax),%eax
8010102f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101032:	8b 45 08             	mov    0x8(%ebp),%eax
80101035:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010103c:	8b 45 08             	mov    0x8(%ebp),%eax
8010103f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101045:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010104c:	e8 2e 40 00 00       	call   8010507f <release>
  
  if(ff.type == FD_PIPE)
80101051:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101054:	83 f8 01             	cmp    $0x1,%eax
80101057:	75 18                	jne    80101071 <fileclose+0xb7>
    pipeclose(ff.pipe, ff.writable);
80101059:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010105d:	0f be d0             	movsbl %al,%edx
80101060:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101063:	89 54 24 04          	mov    %edx,0x4(%esp)
80101067:	89 04 24             	mov    %eax,(%esp)
8010106a:	e8 03 2e 00 00       	call   80103e72 <pipeclose>
8010106f:	eb 1d                	jmp    8010108e <fileclose+0xd4>
  else if(ff.type == FD_INODE){
80101071:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101074:	83 f8 02             	cmp    $0x2,%eax
80101077:	75 15                	jne    8010108e <fileclose+0xd4>
    begin_trans();
80101079:	e8 c7 22 00 00       	call   80103345 <begin_trans>
    iput(ff.ip);
8010107e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101081:	89 04 24             	mov    %eax,(%esp)
80101084:	e8 71 09 00 00       	call   801019fa <iput>
    commit_trans();
80101089:	e8 00 23 00 00       	call   8010338e <commit_trans>
  }
}
8010108e:	c9                   	leave  
8010108f:	c3                   	ret    

80101090 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101090:	55                   	push   %ebp
80101091:	89 e5                	mov    %esp,%ebp
80101093:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101096:	8b 45 08             	mov    0x8(%ebp),%eax
80101099:	8b 00                	mov    (%eax),%eax
8010109b:	83 f8 02             	cmp    $0x2,%eax
8010109e:	75 38                	jne    801010d8 <filestat+0x48>
    ilock(f->ip);
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 40 10             	mov    0x10(%eax),%eax
801010a6:	89 04 24             	mov    %eax,(%esp)
801010a9:	e8 99 07 00 00       	call   80101847 <ilock>
    stati(f->ip, st);
801010ae:	8b 45 08             	mov    0x8(%ebp),%eax
801010b1:	8b 40 10             	mov    0x10(%eax),%eax
801010b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801010b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801010bb:	89 04 24             	mov    %eax,(%esp)
801010be:	e8 c0 0d 00 00       	call   80101e83 <stati>
    iunlock(f->ip);
801010c3:	8b 45 08             	mov    0x8(%ebp),%eax
801010c6:	8b 40 10             	mov    0x10(%eax),%eax
801010c9:	89 04 24             	mov    %eax,(%esp)
801010cc:	e8 c4 08 00 00       	call   80101995 <iunlock>
    return 0;
801010d1:	b8 00 00 00 00       	mov    $0x0,%eax
801010d6:	eb 05                	jmp    801010dd <filestat+0x4d>
  }
  return -1;
801010d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010dd:	c9                   	leave  
801010de:	c3                   	ret    

801010df <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010df:	55                   	push   %ebp
801010e0:	89 e5                	mov    %esp,%ebp
801010e2:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010e5:	8b 45 08             	mov    0x8(%ebp),%eax
801010e8:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801010ec:	84 c0                	test   %al,%al
801010ee:	75 0a                	jne    801010fa <fileread+0x1b>
    return -1;
801010f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010f5:	e9 9f 00 00 00       	jmp    80101199 <fileread+0xba>
  if(f->type == FD_PIPE)
801010fa:	8b 45 08             	mov    0x8(%ebp),%eax
801010fd:	8b 00                	mov    (%eax),%eax
801010ff:	83 f8 01             	cmp    $0x1,%eax
80101102:	75 1e                	jne    80101122 <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 40 0c             	mov    0xc(%eax),%eax
8010110a:	8b 55 10             	mov    0x10(%ebp),%edx
8010110d:	89 54 24 08          	mov    %edx,0x8(%esp)
80101111:	8b 55 0c             	mov    0xc(%ebp),%edx
80101114:	89 54 24 04          	mov    %edx,0x4(%esp)
80101118:	89 04 24             	mov    %eax,(%esp)
8010111b:	e8 d3 2e 00 00       	call   80103ff3 <piperead>
80101120:	eb 77                	jmp    80101199 <fileread+0xba>
  if(f->type == FD_INODE){
80101122:	8b 45 08             	mov    0x8(%ebp),%eax
80101125:	8b 00                	mov    (%eax),%eax
80101127:	83 f8 02             	cmp    $0x2,%eax
8010112a:	75 61                	jne    8010118d <fileread+0xae>
    ilock(f->ip);
8010112c:	8b 45 08             	mov    0x8(%ebp),%eax
8010112f:	8b 40 10             	mov    0x10(%eax),%eax
80101132:	89 04 24             	mov    %eax,(%esp)
80101135:	e8 0d 07 00 00       	call   80101847 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010113a:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010113d:	8b 45 08             	mov    0x8(%ebp),%eax
80101140:	8b 50 14             	mov    0x14(%eax),%edx
80101143:	8b 45 08             	mov    0x8(%ebp),%eax
80101146:	8b 40 10             	mov    0x10(%eax),%eax
80101149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010114d:	89 54 24 08          	mov    %edx,0x8(%esp)
80101151:	8b 55 0c             	mov    0xc(%ebp),%edx
80101154:	89 54 24 04          	mov    %edx,0x4(%esp)
80101158:	89 04 24             	mov    %eax,(%esp)
8010115b:	e8 68 0d 00 00       	call   80101ec8 <readi>
80101160:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101163:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101167:	7e 11                	jle    8010117a <fileread+0x9b>
      f->off += r;
80101169:	8b 45 08             	mov    0x8(%ebp),%eax
8010116c:	8b 50 14             	mov    0x14(%eax),%edx
8010116f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101172:	01 c2                	add    %eax,%edx
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 40 10             	mov    0x10(%eax),%eax
80101180:	89 04 24             	mov    %eax,(%esp)
80101183:	e8 0d 08 00 00       	call   80101995 <iunlock>
    return r;
80101188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010118b:	eb 0c                	jmp    80101199 <fileread+0xba>
  }
  panic("fileread");
8010118d:	c7 04 24 ba 88 10 80 	movl   $0x801088ba,(%esp)
80101194:	e8 a1 f3 ff ff       	call   8010053a <panic>
}
80101199:	c9                   	leave  
8010119a:	c3                   	ret    

8010119b <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010119b:	55                   	push   %ebp
8010119c:	89 e5                	mov    %esp,%ebp
8010119e:	53                   	push   %ebx
8010119f:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801011a2:	8b 45 08             	mov    0x8(%ebp),%eax
801011a5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801011a9:	84 c0                	test   %al,%al
801011ab:	75 0a                	jne    801011b7 <filewrite+0x1c>
    return -1;
801011ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011b2:	e9 20 01 00 00       	jmp    801012d7 <filewrite+0x13c>
  if(f->type == FD_PIPE)
801011b7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ba:	8b 00                	mov    (%eax),%eax
801011bc:	83 f8 01             	cmp    $0x1,%eax
801011bf:	75 21                	jne    801011e2 <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801011c1:	8b 45 08             	mov    0x8(%ebp),%eax
801011c4:	8b 40 0c             	mov    0xc(%eax),%eax
801011c7:	8b 55 10             	mov    0x10(%ebp),%edx
801011ca:	89 54 24 08          	mov    %edx,0x8(%esp)
801011ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801011d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801011d5:	89 04 24             	mov    %eax,(%esp)
801011d8:	e8 27 2d 00 00       	call   80103f04 <pipewrite>
801011dd:	e9 f5 00 00 00       	jmp    801012d7 <filewrite+0x13c>
  if(f->type == FD_INODE){
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 00                	mov    (%eax),%eax
801011e7:	83 f8 02             	cmp    $0x2,%eax
801011ea:	0f 85 db 00 00 00    	jne    801012cb <filewrite+0x130>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801011f0:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801011f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801011fe:	e9 a8 00 00 00       	jmp    801012ab <filewrite+0x110>
      int n1 = n - i;
80101203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101206:	8b 55 10             	mov    0x10(%ebp),%edx
80101209:	29 c2                	sub    %eax,%edx
8010120b:	89 d0                	mov    %edx,%eax
8010120d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101210:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101213:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80101216:	7e 06                	jle    8010121e <filewrite+0x83>
        n1 = max;
80101218:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010121b:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
8010121e:	e8 22 21 00 00       	call   80103345 <begin_trans>
      ilock(f->ip);
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 40 10             	mov    0x10(%eax),%eax
80101229:	89 04 24             	mov    %eax,(%esp)
8010122c:	e8 16 06 00 00       	call   80101847 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101231:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 50 14             	mov    0x14(%eax),%edx
8010123a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010123d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101240:	01 c3                	add    %eax,%ebx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 40 10             	mov    0x10(%eax),%eax
80101248:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010124c:	89 54 24 08          	mov    %edx,0x8(%esp)
80101250:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101254:	89 04 24             	mov    %eax,(%esp)
80101257:	e8 d0 0d 00 00       	call   8010202c <writei>
8010125c:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010125f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101263:	7e 11                	jle    80101276 <filewrite+0xdb>
        f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	89 04 24             	mov    %eax,(%esp)
8010127f:	e8 11 07 00 00       	call   80101995 <iunlock>
      commit_trans();
80101284:	e8 05 21 00 00       	call   8010338e <commit_trans>

      if(r < 0)
80101289:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010128d:	79 02                	jns    80101291 <filewrite+0xf6>
        break;
8010128f:	eb 26                	jmp    801012b7 <filewrite+0x11c>
      if(r != n1)
80101291:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101294:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101297:	74 0c                	je     801012a5 <filewrite+0x10a>
        panic("short filewrite");
80101299:	c7 04 24 c3 88 10 80 	movl   $0x801088c3,(%esp)
801012a0:	e8 95 f2 ff ff       	call   8010053a <panic>
      i += r;
801012a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012a8:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ae:	3b 45 10             	cmp    0x10(%ebp),%eax
801012b1:	0f 8c 4c ff ff ff    	jl     80101203 <filewrite+0x68>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801012b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012ba:	3b 45 10             	cmp    0x10(%ebp),%eax
801012bd:	75 05                	jne    801012c4 <filewrite+0x129>
801012bf:	8b 45 10             	mov    0x10(%ebp),%eax
801012c2:	eb 05                	jmp    801012c9 <filewrite+0x12e>
801012c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012c9:	eb 0c                	jmp    801012d7 <filewrite+0x13c>
  }
  panic("filewrite");
801012cb:	c7 04 24 d3 88 10 80 	movl   $0x801088d3,(%esp)
801012d2:	e8 63 f2 ff ff       	call   8010053a <panic>
}
801012d7:	83 c4 24             	add    $0x24,%esp
801012da:	5b                   	pop    %ebx
801012db:	5d                   	pop    %ebp
801012dc:	c3                   	ret    

801012dd <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012dd:	55                   	push   %ebp
801012de:	89 e5                	mov    %esp,%ebp
801012e0:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012e3:	8b 45 08             	mov    0x8(%ebp),%eax
801012e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801012ed:	00 
801012ee:	89 04 24             	mov    %eax,(%esp)
801012f1:	e8 b0 ee ff ff       	call   801001a6 <bread>
801012f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801012f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012fc:	83 c0 18             	add    $0x18,%eax
801012ff:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101306:	00 
80101307:	89 44 24 04          	mov    %eax,0x4(%esp)
8010130b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010130e:	89 04 24             	mov    %eax,(%esp)
80101311:	e8 2a 40 00 00       	call   80105340 <memmove>
  brelse(bp);
80101316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101319:	89 04 24             	mov    %eax,(%esp)
8010131c:	e8 f6 ee ff ff       	call   80100217 <brelse>
}
80101321:	c9                   	leave  
80101322:	c3                   	ret    

80101323 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101323:	55                   	push   %ebp
80101324:	89 e5                	mov    %esp,%ebp
80101326:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101329:	8b 55 0c             	mov    0xc(%ebp),%edx
8010132c:	8b 45 08             	mov    0x8(%ebp),%eax
8010132f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101333:	89 04 24             	mov    %eax,(%esp)
80101336:	e8 6b ee ff ff       	call   801001a6 <bread>
8010133b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010133e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101341:	83 c0 18             	add    $0x18,%eax
80101344:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010134b:	00 
8010134c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101353:	00 
80101354:	89 04 24             	mov    %eax,(%esp)
80101357:	e8 15 3f 00 00       	call   80105271 <memset>
  log_write(bp);
8010135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010135f:	89 04 24             	mov    %eax,(%esp)
80101362:	e8 7f 20 00 00       	call   801033e6 <log_write>
  brelse(bp);
80101367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136a:	89 04 24             	mov    %eax,(%esp)
8010136d:	e8 a5 ee ff ff       	call   80100217 <brelse>
}
80101372:	c9                   	leave  
80101373:	c3                   	ret    

80101374 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101374:	55                   	push   %ebp
80101375:	89 e5                	mov    %esp,%ebp
80101377:	83 ec 38             	sub    $0x38,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
8010137a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101381:	8b 45 08             	mov    0x8(%ebp),%eax
80101384:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101387:	89 54 24 04          	mov    %edx,0x4(%esp)
8010138b:	89 04 24             	mov    %eax,(%esp)
8010138e:	e8 4a ff ff ff       	call   801012dd <readsb>
  for(b = 0; b < sb.size; b += BPB){
80101393:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010139a:	e9 07 01 00 00       	jmp    801014a6 <balloc+0x132>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010139f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801013a8:	85 c0                	test   %eax,%eax
801013aa:	0f 48 c2             	cmovs  %edx,%eax
801013ad:	c1 f8 0c             	sar    $0xc,%eax
801013b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
801013b3:	c1 ea 03             	shr    $0x3,%edx
801013b6:	01 d0                	add    %edx,%eax
801013b8:	83 c0 03             	add    $0x3,%eax
801013bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801013bf:	8b 45 08             	mov    0x8(%ebp),%eax
801013c2:	89 04 24             	mov    %eax,(%esp)
801013c5:	e8 dc ed ff ff       	call   801001a6 <bread>
801013ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013d4:	e9 9d 00 00 00       	jmp    80101476 <balloc+0x102>
      m = 1 << (bi % 8);
801013d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013dc:	99                   	cltd   
801013dd:	c1 ea 1d             	shr    $0x1d,%edx
801013e0:	01 d0                	add    %edx,%eax
801013e2:	83 e0 07             	and    $0x7,%eax
801013e5:	29 d0                	sub    %edx,%eax
801013e7:	ba 01 00 00 00       	mov    $0x1,%edx
801013ec:	89 c1                	mov    %eax,%ecx
801013ee:	d3 e2                	shl    %cl,%edx
801013f0:	89 d0                	mov    %edx,%eax
801013f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f8:	8d 50 07             	lea    0x7(%eax),%edx
801013fb:	85 c0                	test   %eax,%eax
801013fd:	0f 48 c2             	cmovs  %edx,%eax
80101400:	c1 f8 03             	sar    $0x3,%eax
80101403:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101406:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010140b:	0f b6 c0             	movzbl %al,%eax
8010140e:	23 45 e8             	and    -0x18(%ebp),%eax
80101411:	85 c0                	test   %eax,%eax
80101413:	75 5d                	jne    80101472 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
80101415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101418:	8d 50 07             	lea    0x7(%eax),%edx
8010141b:	85 c0                	test   %eax,%eax
8010141d:	0f 48 c2             	cmovs  %edx,%eax
80101420:	c1 f8 03             	sar    $0x3,%eax
80101423:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101426:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010142b:	89 d1                	mov    %edx,%ecx
8010142d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101430:	09 ca                	or     %ecx,%edx
80101432:	89 d1                	mov    %edx,%ecx
80101434:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101437:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010143b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010143e:	89 04 24             	mov    %eax,(%esp)
80101441:	e8 a0 1f 00 00       	call   801033e6 <log_write>
        brelse(bp);
80101446:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101449:	89 04 24             	mov    %eax,(%esp)
8010144c:	e8 c6 ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101454:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101457:	01 c2                	add    %eax,%edx
80101459:	8b 45 08             	mov    0x8(%ebp),%eax
8010145c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101460:	89 04 24             	mov    %eax,(%esp)
80101463:	e8 bb fe ff ff       	call   80101323 <bzero>
        return b + bi;
80101468:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010146e:	01 d0                	add    %edx,%eax
80101470:	eb 4e                	jmp    801014c0 <balloc+0x14c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101472:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101476:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010147d:	7f 15                	jg     80101494 <balloc+0x120>
8010147f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101482:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101485:	01 d0                	add    %edx,%eax
80101487:	89 c2                	mov    %eax,%edx
80101489:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010148c:	39 c2                	cmp    %eax,%edx
8010148e:	0f 82 45 ff ff ff    	jb     801013d9 <balloc+0x65>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101494:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101497:	89 04 24             	mov    %eax,(%esp)
8010149a:	e8 78 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
8010149f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801014a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801014ac:	39 c2                	cmp    %eax,%edx
801014ae:	0f 82 eb fe ff ff    	jb     8010139f <balloc+0x2b>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801014b4:	c7 04 24 dd 88 10 80 	movl   $0x801088dd,(%esp)
801014bb:	e8 7a f0 ff ff       	call   8010053a <panic>
}
801014c0:	c9                   	leave  
801014c1:	c3                   	ret    

801014c2 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801014c2:	55                   	push   %ebp
801014c3:	89 e5                	mov    %esp,%ebp
801014c5:	83 ec 38             	sub    $0x38,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014c8:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801014cf:	8b 45 08             	mov    0x8(%ebp),%eax
801014d2:	89 04 24             	mov    %eax,(%esp)
801014d5:	e8 03 fe ff ff       	call   801012dd <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014da:	8b 45 0c             	mov    0xc(%ebp),%eax
801014dd:	c1 e8 0c             	shr    $0xc,%eax
801014e0:	89 c2                	mov    %eax,%edx
801014e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014e5:	c1 e8 03             	shr    $0x3,%eax
801014e8:	01 d0                	add    %edx,%eax
801014ea:	8d 50 03             	lea    0x3(%eax),%edx
801014ed:	8b 45 08             	mov    0x8(%ebp),%eax
801014f0:	89 54 24 04          	mov    %edx,0x4(%esp)
801014f4:	89 04 24             	mov    %eax,(%esp)
801014f7:	e8 aa ec ff ff       	call   801001a6 <bread>
801014fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80101502:	25 ff 0f 00 00       	and    $0xfff,%eax
80101507:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150d:	99                   	cltd   
8010150e:	c1 ea 1d             	shr    $0x1d,%edx
80101511:	01 d0                	add    %edx,%eax
80101513:	83 e0 07             	and    $0x7,%eax
80101516:	29 d0                	sub    %edx,%eax
80101518:	ba 01 00 00 00       	mov    $0x1,%edx
8010151d:	89 c1                	mov    %eax,%ecx
8010151f:	d3 e2                	shl    %cl,%edx
80101521:	89 d0                	mov    %edx,%eax
80101523:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101529:	8d 50 07             	lea    0x7(%eax),%edx
8010152c:	85 c0                	test   %eax,%eax
8010152e:	0f 48 c2             	cmovs  %edx,%eax
80101531:	c1 f8 03             	sar    $0x3,%eax
80101534:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101537:	0f b6 44 02 18       	movzbl 0x18(%edx,%eax,1),%eax
8010153c:	0f b6 c0             	movzbl %al,%eax
8010153f:	23 45 ec             	and    -0x14(%ebp),%eax
80101542:	85 c0                	test   %eax,%eax
80101544:	75 0c                	jne    80101552 <bfree+0x90>
    panic("freeing free block");
80101546:	c7 04 24 f3 88 10 80 	movl   $0x801088f3,(%esp)
8010154d:	e8 e8 ef ff ff       	call   8010053a <panic>
  bp->data[bi/8] &= ~m;
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	8d 50 07             	lea    0x7(%eax),%edx
80101558:	85 c0                	test   %eax,%eax
8010155a:	0f 48 c2             	cmovs  %edx,%eax
8010155d:	c1 f8 03             	sar    $0x3,%eax
80101560:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101563:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101568:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010156b:	f7 d1                	not    %ecx
8010156d:	21 ca                	and    %ecx,%edx
8010156f:	89 d1                	mov    %edx,%ecx
80101571:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101574:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010157b:	89 04 24             	mov    %eax,(%esp)
8010157e:	e8 63 1e 00 00       	call   801033e6 <log_write>
  brelse(bp);
80101583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101586:	89 04 24             	mov    %eax,(%esp)
80101589:	e8 89 ec ff ff       	call   80100217 <brelse>
}
8010158e:	c9                   	leave  
8010158f:	c3                   	ret    

80101590 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101590:	55                   	push   %ebp
80101591:	89 e5                	mov    %esp,%ebp
80101593:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101596:	c7 44 24 04 06 89 10 	movl   $0x80108906,0x4(%esp)
8010159d:	80 
8010159e:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801015a5:	e8 52 3a 00 00       	call   80104ffc <initlock>
}
801015aa:	c9                   	leave  
801015ab:	c3                   	ret    

801015ac <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801015ac:	55                   	push   %ebp
801015ad:	89 e5                	mov    %esp,%ebp
801015af:	83 ec 38             	sub    $0x38,%esp
801015b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801015b5:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
801015b9:	8b 45 08             	mov    0x8(%ebp),%eax
801015bc:	8d 55 dc             	lea    -0x24(%ebp),%edx
801015bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801015c3:	89 04 24             	mov    %eax,(%esp)
801015c6:	e8 12 fd ff ff       	call   801012dd <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015cb:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015d2:	e9 98 00 00 00       	jmp    8010166f <ialloc+0xc3>
    bp = bread(dev, IBLOCK(inum));
801015d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015da:	c1 e8 03             	shr    $0x3,%eax
801015dd:	83 c0 02             	add    $0x2,%eax
801015e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801015e4:	8b 45 08             	mov    0x8(%ebp),%eax
801015e7:	89 04 24             	mov    %eax,(%esp)
801015ea:	e8 b7 eb ff ff       	call   801001a6 <bread>
801015ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801015f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f5:	8d 50 18             	lea    0x18(%eax),%edx
801015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fb:	83 e0 07             	and    $0x7,%eax
801015fe:	c1 e0 06             	shl    $0x6,%eax
80101601:	01 d0                	add    %edx,%eax
80101603:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101606:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101609:	0f b7 00             	movzwl (%eax),%eax
8010160c:	66 85 c0             	test   %ax,%ax
8010160f:	75 4f                	jne    80101660 <ialloc+0xb4>
      memset(dip, 0, sizeof(*dip));
80101611:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101618:	00 
80101619:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101620:	00 
80101621:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101624:	89 04 24             	mov    %eax,(%esp)
80101627:	e8 45 3c 00 00       	call   80105271 <memset>
      dip->type = type;
8010162c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010162f:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
80101633:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101639:	89 04 24             	mov    %eax,(%esp)
8010163c:	e8 a5 1d 00 00       	call   801033e6 <log_write>
      brelse(bp);
80101641:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101644:	89 04 24             	mov    %eax,(%esp)
80101647:	e8 cb eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010164c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010164f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101653:	8b 45 08             	mov    0x8(%ebp),%eax
80101656:	89 04 24             	mov    %eax,(%esp)
80101659:	e8 e5 00 00 00       	call   80101743 <iget>
8010165e:	eb 29                	jmp    80101689 <ialloc+0xdd>
    }
    brelse(bp);
80101660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101663:	89 04 24             	mov    %eax,(%esp)
80101666:	e8 ac eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
8010166b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010166f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101672:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101675:	39 c2                	cmp    %eax,%edx
80101677:	0f 82 5a ff ff ff    	jb     801015d7 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010167d:	c7 04 24 0d 89 10 80 	movl   $0x8010890d,(%esp)
80101684:	e8 b1 ee ff ff       	call   8010053a <panic>
}
80101689:	c9                   	leave  
8010168a:	c3                   	ret    

8010168b <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010168b:	55                   	push   %ebp
8010168c:	89 e5                	mov    %esp,%ebp
8010168e:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
80101691:	8b 45 08             	mov    0x8(%ebp),%eax
80101694:	8b 40 04             	mov    0x4(%eax),%eax
80101697:	c1 e8 03             	shr    $0x3,%eax
8010169a:	8d 50 02             	lea    0x2(%eax),%edx
8010169d:	8b 45 08             	mov    0x8(%ebp),%eax
801016a0:	8b 00                	mov    (%eax),%eax
801016a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801016a6:	89 04 24             	mov    %eax,(%esp)
801016a9:	e8 f8 ea ff ff       	call   801001a6 <bread>
801016ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b4:	8d 50 18             	lea    0x18(%eax),%edx
801016b7:	8b 45 08             	mov    0x8(%ebp),%eax
801016ba:	8b 40 04             	mov    0x4(%eax),%eax
801016bd:	83 e0 07             	and    $0x7,%eax
801016c0:	c1 e0 06             	shl    $0x6,%eax
801016c3:	01 d0                	add    %edx,%eax
801016c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016c8:	8b 45 08             	mov    0x8(%ebp),%eax
801016cb:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801016cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d2:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801016d5:	8b 45 08             	mov    0x8(%ebp),%eax
801016d8:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016df:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801016e3:	8b 45 08             	mov    0x8(%ebp),%eax
801016e6:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801016ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ed:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801016f1:	8b 45 08             	mov    0x8(%ebp),%eax
801016f4:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801016f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fb:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801016ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101702:	8b 50 18             	mov    0x18(%eax),%edx
80101705:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101708:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010170b:	8b 45 08             	mov    0x8(%ebp),%eax
8010170e:	8d 50 1c             	lea    0x1c(%eax),%edx
80101711:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101714:	83 c0 0c             	add    $0xc,%eax
80101717:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010171e:	00 
8010171f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101723:	89 04 24             	mov    %eax,(%esp)
80101726:	e8 15 3c 00 00       	call   80105340 <memmove>
  log_write(bp);
8010172b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010172e:	89 04 24             	mov    %eax,(%esp)
80101731:	e8 b0 1c 00 00       	call   801033e6 <log_write>
  brelse(bp);
80101736:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101739:	89 04 24             	mov    %eax,(%esp)
8010173c:	e8 d6 ea ff ff       	call   80100217 <brelse>
}
80101741:	c9                   	leave  
80101742:	c3                   	ret    

80101743 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101743:	55                   	push   %ebp
80101744:	89 e5                	mov    %esp,%ebp
80101746:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101749:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101750:	e8 c8 38 00 00       	call   8010501d <acquire>

  // Is the inode already cached?
  empty = 0;
80101755:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010175c:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
80101763:	eb 59                	jmp    801017be <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101768:	8b 40 08             	mov    0x8(%eax),%eax
8010176b:	85 c0                	test   %eax,%eax
8010176d:	7e 35                	jle    801017a4 <iget+0x61>
8010176f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101772:	8b 00                	mov    (%eax),%eax
80101774:	3b 45 08             	cmp    0x8(%ebp),%eax
80101777:	75 2b                	jne    801017a4 <iget+0x61>
80101779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177c:	8b 40 04             	mov    0x4(%eax),%eax
8010177f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101782:	75 20                	jne    801017a4 <iget+0x61>
      ip->ref++;
80101784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101787:	8b 40 08             	mov    0x8(%eax),%eax
8010178a:	8d 50 01             	lea    0x1(%eax),%edx
8010178d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101790:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101793:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010179a:	e8 e0 38 00 00       	call   8010507f <release>
      return ip;
8010179f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a2:	eb 6f                	jmp    80101813 <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801017a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017a8:	75 10                	jne    801017ba <iget+0x77>
801017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ad:	8b 40 08             	mov    0x8(%eax),%eax
801017b0:	85 c0                	test   %eax,%eax
801017b2:	75 06                	jne    801017ba <iget+0x77>
      empty = ip;
801017b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017b7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801017ba:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801017be:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
801017c5:	72 9e                	jb     80101765 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017c7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017cb:	75 0c                	jne    801017d9 <iget+0x96>
    panic("iget: no inodes");
801017cd:	c7 04 24 1f 89 10 80 	movl   $0x8010891f,(%esp)
801017d4:	e8 61 ed ff ff       	call   8010053a <panic>

  ip = empty;
801017d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e2:	8b 55 08             	mov    0x8(%ebp),%edx
801017e5:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801017ed:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017f3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017fd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101804:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010180b:	e8 6f 38 00 00       	call   8010507f <release>

  return ip;
80101810:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101813:	c9                   	leave  
80101814:	c3                   	ret    

80101815 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
8010181b:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101822:	e8 f6 37 00 00       	call   8010501d <acquire>
  ip->ref++;
80101827:	8b 45 08             	mov    0x8(%ebp),%eax
8010182a:	8b 40 08             	mov    0x8(%eax),%eax
8010182d:	8d 50 01             	lea    0x1(%eax),%edx
80101830:	8b 45 08             	mov    0x8(%ebp),%eax
80101833:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101836:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010183d:	e8 3d 38 00 00       	call   8010507f <release>
  return ip;
80101842:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101845:	c9                   	leave  
80101846:	c3                   	ret    

80101847 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101847:	55                   	push   %ebp
80101848:	89 e5                	mov    %esp,%ebp
8010184a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010184d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101851:	74 0a                	je     8010185d <ilock+0x16>
80101853:	8b 45 08             	mov    0x8(%ebp),%eax
80101856:	8b 40 08             	mov    0x8(%eax),%eax
80101859:	85 c0                	test   %eax,%eax
8010185b:	7f 0c                	jg     80101869 <ilock+0x22>
    panic("ilock");
8010185d:	c7 04 24 2f 89 10 80 	movl   $0x8010892f,(%esp)
80101864:	e8 d1 ec ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
80101869:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101870:	e8 a8 37 00 00       	call   8010501d <acquire>
  while(ip->flags & I_BUSY)
80101875:	eb 13                	jmp    8010188a <ilock+0x43>
    sleep(ip, &icache.lock);
80101877:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
8010187e:	80 
8010187f:	8b 45 08             	mov    0x8(%ebp),%eax
80101882:	89 04 24             	mov    %eax,(%esp)
80101885:	e8 11 31 00 00       	call   8010499b <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
8010188a:	8b 45 08             	mov    0x8(%ebp),%eax
8010188d:	8b 40 0c             	mov    0xc(%eax),%eax
80101890:	83 e0 01             	and    $0x1,%eax
80101893:	85 c0                	test   %eax,%eax
80101895:	75 e0                	jne    80101877 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101897:	8b 45 08             	mov    0x8(%ebp),%eax
8010189a:	8b 40 0c             	mov    0xc(%eax),%eax
8010189d:	83 c8 01             	or     $0x1,%eax
801018a0:	89 c2                	mov    %eax,%edx
801018a2:	8b 45 08             	mov    0x8(%ebp),%eax
801018a5:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801018a8:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801018af:	e8 cb 37 00 00       	call   8010507f <release>

  if(!(ip->flags & I_VALID)){
801018b4:	8b 45 08             	mov    0x8(%ebp),%eax
801018b7:	8b 40 0c             	mov    0xc(%eax),%eax
801018ba:	83 e0 02             	and    $0x2,%eax
801018bd:	85 c0                	test   %eax,%eax
801018bf:	0f 85 ce 00 00 00    	jne    80101993 <ilock+0x14c>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018c5:	8b 45 08             	mov    0x8(%ebp),%eax
801018c8:	8b 40 04             	mov    0x4(%eax),%eax
801018cb:	c1 e8 03             	shr    $0x3,%eax
801018ce:	8d 50 02             	lea    0x2(%eax),%edx
801018d1:	8b 45 08             	mov    0x8(%ebp),%eax
801018d4:	8b 00                	mov    (%eax),%eax
801018d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801018da:	89 04 24             	mov    %eax,(%esp)
801018dd:	e8 c4 e8 ff ff       	call   801001a6 <bread>
801018e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e8:	8d 50 18             	lea    0x18(%eax),%edx
801018eb:	8b 45 08             	mov    0x8(%ebp),%eax
801018ee:	8b 40 04             	mov    0x4(%eax),%eax
801018f1:	83 e0 07             	and    $0x7,%eax
801018f4:	c1 e0 06             	shl    $0x6,%eax
801018f7:	01 d0                	add    %edx,%eax
801018f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801018fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ff:	0f b7 10             	movzwl (%eax),%edx
80101902:	8b 45 08             	mov    0x8(%ebp),%eax
80101905:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101909:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101910:	8b 45 08             	mov    0x8(%ebp),%eax
80101913:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101917:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101925:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101928:	0f b7 50 06          	movzwl 0x6(%eax),%edx
8010192c:	8b 45 08             	mov    0x8(%ebp),%eax
8010192f:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101936:	8b 50 08             	mov    0x8(%eax),%edx
80101939:	8b 45 08             	mov    0x8(%ebp),%eax
8010193c:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101942:	8d 50 0c             	lea    0xc(%eax),%edx
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	83 c0 1c             	add    $0x1c,%eax
8010194b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101952:	00 
80101953:	89 54 24 04          	mov    %edx,0x4(%esp)
80101957:	89 04 24             	mov    %eax,(%esp)
8010195a:	e8 e1 39 00 00       	call   80105340 <memmove>
    brelse(bp);
8010195f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101962:	89 04 24             	mov    %eax,(%esp)
80101965:	e8 ad e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
8010196a:	8b 45 08             	mov    0x8(%ebp),%eax
8010196d:	8b 40 0c             	mov    0xc(%eax),%eax
80101970:	83 c8 02             	or     $0x2,%eax
80101973:	89 c2                	mov    %eax,%edx
80101975:	8b 45 08             	mov    0x8(%ebp),%eax
80101978:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
8010197b:	8b 45 08             	mov    0x8(%ebp),%eax
8010197e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101982:	66 85 c0             	test   %ax,%ax
80101985:	75 0c                	jne    80101993 <ilock+0x14c>
      panic("ilock: no type");
80101987:	c7 04 24 35 89 10 80 	movl   $0x80108935,(%esp)
8010198e:	e8 a7 eb ff ff       	call   8010053a <panic>
  }
}
80101993:	c9                   	leave  
80101994:	c3                   	ret    

80101995 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101995:	55                   	push   %ebp
80101996:	89 e5                	mov    %esp,%ebp
80101998:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
8010199b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010199f:	74 17                	je     801019b8 <iunlock+0x23>
801019a1:	8b 45 08             	mov    0x8(%ebp),%eax
801019a4:	8b 40 0c             	mov    0xc(%eax),%eax
801019a7:	83 e0 01             	and    $0x1,%eax
801019aa:	85 c0                	test   %eax,%eax
801019ac:	74 0a                	je     801019b8 <iunlock+0x23>
801019ae:	8b 45 08             	mov    0x8(%ebp),%eax
801019b1:	8b 40 08             	mov    0x8(%eax),%eax
801019b4:	85 c0                	test   %eax,%eax
801019b6:	7f 0c                	jg     801019c4 <iunlock+0x2f>
    panic("iunlock");
801019b8:	c7 04 24 44 89 10 80 	movl   $0x80108944,(%esp)
801019bf:	e8 76 eb ff ff       	call   8010053a <panic>

  acquire(&icache.lock);
801019c4:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801019cb:	e8 4d 36 00 00       	call   8010501d <acquire>
  ip->flags &= ~I_BUSY;
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	8b 40 0c             	mov    0xc(%eax),%eax
801019d6:	83 e0 fe             	and    $0xfffffffe,%eax
801019d9:	89 c2                	mov    %eax,%edx
801019db:	8b 45 08             	mov    0x8(%ebp),%eax
801019de:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019e1:	8b 45 08             	mov    0x8(%ebp),%eax
801019e4:	89 04 24             	mov    %eax,(%esp)
801019e7:	e8 8b 30 00 00       	call   80104a77 <wakeup>
  release(&icache.lock);
801019ec:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801019f3:	e8 87 36 00 00       	call   8010507f <release>
}
801019f8:	c9                   	leave  
801019f9:	c3                   	ret    

801019fa <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
801019fa:	55                   	push   %ebp
801019fb:	89 e5                	mov    %esp,%ebp
801019fd:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a00:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a07:	e8 11 36 00 00       	call   8010501d <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0f:	8b 40 08             	mov    0x8(%eax),%eax
80101a12:	83 f8 01             	cmp    $0x1,%eax
80101a15:	0f 85 93 00 00 00    	jne    80101aae <iput+0xb4>
80101a1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1e:	8b 40 0c             	mov    0xc(%eax),%eax
80101a21:	83 e0 02             	and    $0x2,%eax
80101a24:	85 c0                	test   %eax,%eax
80101a26:	0f 84 82 00 00 00    	je     80101aae <iput+0xb4>
80101a2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101a33:	66 85 c0             	test   %ax,%ax
80101a36:	75 76                	jne    80101aae <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a38:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3b:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3e:	83 e0 01             	and    $0x1,%eax
80101a41:	85 c0                	test   %eax,%eax
80101a43:	74 0c                	je     80101a51 <iput+0x57>
      panic("iput busy");
80101a45:	c7 04 24 4c 89 10 80 	movl   $0x8010894c,(%esp)
80101a4c:	e8 e9 ea ff ff       	call   8010053a <panic>
    ip->flags |= I_BUSY;
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	8b 40 0c             	mov    0xc(%eax),%eax
80101a57:	83 c8 01             	or     $0x1,%eax
80101a5a:	89 c2                	mov    %eax,%edx
80101a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5f:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a62:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a69:	e8 11 36 00 00       	call   8010507f <release>
    itrunc(ip);
80101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a71:	89 04 24             	mov    %eax,(%esp)
80101a74:	e8 ef 02 00 00       	call   80101d68 <itrunc>
    ip->type = 0;
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a82:	8b 45 08             	mov    0x8(%ebp),%eax
80101a85:	89 04 24             	mov    %eax,(%esp)
80101a88:	e8 fe fb ff ff       	call   8010168b <iupdate>
    acquire(&icache.lock);
80101a8d:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a94:	e8 84 35 00 00       	call   8010501d <acquire>
    ip->flags = 0;
80101a99:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	89 04 24             	mov    %eax,(%esp)
80101aa9:	e8 c9 2f 00 00       	call   80104a77 <wakeup>
  }
  ip->ref--;
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 40 08             	mov    0x8(%eax),%eax
80101ab4:	8d 50 ff             	lea    -0x1(%eax),%edx
80101ab7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aba:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101abd:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101ac4:	e8 b6 35 00 00       	call   8010507f <release>
}
80101ac9:	c9                   	leave  
80101aca:	c3                   	ret    

80101acb <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101acb:	55                   	push   %ebp
80101acc:	89 e5                	mov    %esp,%ebp
80101ace:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad4:	89 04 24             	mov    %eax,(%esp)
80101ad7:	e8 b9 fe ff ff       	call   80101995 <iunlock>
  iput(ip);
80101adc:	8b 45 08             	mov    0x8(%ebp),%eax
80101adf:	89 04 24             	mov    %eax,(%esp)
80101ae2:	e8 13 ff ff ff       	call   801019fa <iput>
}
80101ae7:	c9                   	leave  
80101ae8:	c3                   	ret    

80101ae9 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ae9:	55                   	push   %ebp
80101aea:	89 e5                	mov    %esp,%ebp
80101aec:	53                   	push   %ebx
80101aed:	83 ec 44             	sub    $0x44,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101af0:	83 7d 0c 09          	cmpl   $0x9,0xc(%ebp)
80101af4:	77 3e                	ja     80101b34 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101af6:	8b 45 08             	mov    0x8(%ebp),%eax
80101af9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101afc:	83 c2 04             	add    $0x4,%edx
80101aff:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b0a:	75 20                	jne    80101b2c <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0f:	8b 00                	mov    (%eax),%eax
80101b11:	89 04 24             	mov    %eax,(%esp)
80101b14:	e8 5b f8 ff ff       	call   80101374 <balloc>
80101b19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101b22:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b25:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b28:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b2f:	e9 2e 02 00 00       	jmp    80101d62 <bmap+0x279>
  }
  bn -= NDIRECT;
80101b34:	83 6d 0c 0a          	subl   $0xa,0xc(%ebp)

  if(bn < NINDIRECT){
80101b38:	81 7d 0c ff 00 00 00 	cmpl   $0xff,0xc(%ebp)
80101b3f:	0f 87 d4 00 00 00    	ja     80101c19 <bmap+0x130>

    // Load indirect block, allocating if necessary.
    int index = 0;
80101b45:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    if(bn < NBLOCK) {
80101b4c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b50:	77 09                	ja     80101b5b <bmap+0x72>
      index = 10;
80101b52:	c7 45 f0 0a 00 00 00 	movl   $0xa,-0x10(%ebp)
80101b59:	eb 0b                	jmp    80101b66 <bmap+0x7d>
    } else{
      index = 11;
80101b5b:	c7 45 f0 0b 00 00 00 	movl   $0xb,-0x10(%ebp)
      bn -= NBLOCK;
80101b62:	83 45 0c 80          	addl   $0xffffff80,0xc(%ebp)
    }

    if((addr = ip->addrs[index]) == 0)
80101b66:	8b 45 08             	mov    0x8(%ebp),%eax
80101b69:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101b6c:	83 c2 04             	add    $0x4,%edx
80101b6f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101b73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b7a:	75 20                	jne    80101b9c <bmap+0xb3>
      ip->addrs[index] = addr = balloc(ip->dev);
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	8b 00                	mov    (%eax),%eax
80101b81:	89 04 24             	mov    %eax,(%esp)
80101b84:	e8 eb f7 ff ff       	call   80101374 <balloc>
80101b89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101b92:	8d 4a 04             	lea    0x4(%edx),%ecx
80101b95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b98:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    bp = bread(ip->dev, addr);
80101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9f:	8b 00                	mov    (%eax),%eax
80101ba1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ba4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ba8:	89 04 24             	mov    %eax,(%esp)
80101bab:	e8 f6 e5 ff ff       	call   801001a6 <bread>
80101bb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101bb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bb6:	83 c0 18             	add    $0x18,%eax
80101bb9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if((addr = a[bn]) == 0){
80101bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bbf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101bc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101bc9:	01 d0                	add    %edx,%eax
80101bcb:	8b 00                	mov    (%eax),%eax
80101bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101bd4:	75 30                	jne    80101c06 <bmap+0x11d>
      a[bn] = addr = balloc(ip->dev);
80101bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101bd9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101be0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101be3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101be6:	8b 45 08             	mov    0x8(%ebp),%eax
80101be9:	8b 00                	mov    (%eax),%eax
80101beb:	89 04 24             	mov    %eax,(%esp)
80101bee:	e8 81 f7 ff ff       	call   80101374 <balloc>
80101bf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bf9:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101bfb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101bfe:	89 04 24             	mov    %eax,(%esp)
80101c01:	e8 e0 17 00 00       	call   801033e6 <log_write>
    }
    brelse(bp);
80101c06:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c09:	89 04 24             	mov    %eax,(%esp)
80101c0c:	e8 06 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c14:	e9 49 01 00 00       	jmp    80101d62 <bmap+0x279>
  }

  bn -= 2 * NBLOCK;
80101c19:	81 6d 0c 00 01 00 00 	subl   $0x100,0xc(%ebp)

  if(bn < NDINDIRECT) {
80101c20:	81 7d 0c ff 3f 00 00 	cmpl   $0x3fff,0xc(%ebp)
80101c27:	0f 87 29 01 00 00    	ja     80101d56 <bmap+0x26d>

    int index_1 = bn / NBLOCK;
80101c2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c30:	c1 e8 07             	shr    $0x7,%eax
80101c33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int index_2 = bn % NBLOCK;
80101c36:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c39:	83 e0 7f             	and    $0x7f,%eax
80101c3c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 
    if((addr = ip->addrs[12]) == 0)
80101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c42:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c45:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c48:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c4c:	75 19                	jne    80101c67 <bmap+0x17e>
      ip->addrs[12] = addr = balloc(ip->dev);
80101c4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c51:	8b 00                	mov    (%eax),%eax
80101c53:	89 04 24             	mov    %eax,(%esp)
80101c56:	e8 19 f7 ff ff       	call   80101374 <balloc>
80101c5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c64:	89 50 4c             	mov    %edx,0x4c(%eax)

    struct buf *bp1 = bread(ip->dev, addr); //addr, bp: allocated 1st layer index node
80101c67:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6a:	8b 00                	mov    (%eax),%eax
80101c6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c6f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c73:	89 04 24             	mov    %eax,(%esp)
80101c76:	e8 2b e5 ff ff       	call   801001a6 <bread>
80101c7b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    uint *a1 = (uint*)bp1->data; 
80101c7e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101c81:	83 c0 18             	add    $0x18,%eax
80101c84:	89 45 d8             	mov    %eax,-0x28(%ebp)

    if((addr = a1[index_1]) == 0){
80101c87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c91:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101c94:	01 d0                	add    %edx,%eax
80101c96:	8b 00                	mov    (%eax),%eax
80101c98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c9f:	75 30                	jne    80101cd1 <bmap+0x1e8>
      a1[index_1] = addr = balloc(ip->dev); //addr, a[bn]: allocated 2st layer index node
80101ca1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101ca4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cab:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101cae:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101cb1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb4:	8b 00                	mov    (%eax),%eax
80101cb6:	89 04 24             	mov    %eax,(%esp)
80101cb9:	e8 b6 f6 ff ff       	call   80101374 <balloc>
80101cbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cc4:	89 03                	mov    %eax,(%ebx)
      log_write(bp1); // update index node at layer 1
80101cc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101cc9:	89 04 24             	mov    %eax,(%esp)
80101ccc:	e8 15 17 00 00       	call   801033e6 <log_write>
    }
    brelse(bp1);
80101cd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101cd4:	89 04 24             	mov    %eax,(%esp)
80101cd7:	e8 3b e5 ff ff       	call   80100217 <brelse>

    struct buf *bp2 = bread(ip->dev, addr);
80101cdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdf:	8b 00                	mov    (%eax),%eax
80101ce1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101ce4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ce8:	89 04 24             	mov    %eax,(%esp)
80101ceb:	e8 b6 e4 ff ff       	call   801001a6 <bread>
80101cf0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    uint *a2 = (uint*)bp2->data; 
80101cf3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101cf6:	83 c0 18             	add    $0x18,%eax
80101cf9:	89 45 d0             	mov    %eax,-0x30(%ebp)
    
    if((addr = a2[index_2]) == 0){
80101cfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101cff:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d06:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101d09:	01 d0                	add    %edx,%eax
80101d0b:	8b 00                	mov    (%eax),%eax
80101d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d14:	75 30                	jne    80101d46 <bmap+0x25d>
      a2[index_2] = addr = balloc(ip->dev); // allocate data block
80101d16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101d19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d20:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101d23:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 00                	mov    (%eax),%eax
80101d2b:	89 04 24             	mov    %eax,(%esp)
80101d2e:	e8 41 f6 ff ff       	call   80101374 <balloc>
80101d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d39:	89 03                	mov    %eax,(%ebx)
      log_write(bp2); 
80101d3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101d3e:	89 04 24             	mov    %eax,(%esp)
80101d41:	e8 a0 16 00 00       	call   801033e6 <log_write>
    }

    brelse(bp2);
80101d46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101d49:	89 04 24             	mov    %eax,(%esp)
80101d4c:	e8 c6 e4 ff ff       	call   80100217 <brelse>
    // need to allocate data node, and update index node at layer 2
    return addr;
80101d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d54:	eb 0c                	jmp    80101d62 <bmap+0x279>

  }
  panic("bmap: out of range");
80101d56:	c7 04 24 56 89 10 80 	movl   $0x80108956,(%esp)
80101d5d:	e8 d8 e7 ff ff       	call   8010053a <panic>
}
80101d62:	83 c4 44             	add    $0x44,%esp
80101d65:	5b                   	pop    %ebx
80101d66:	5d                   	pop    %ebp
80101d67:	c3                   	ret    

80101d68 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d75:	eb 44                	jmp    80101dbb <itrunc+0x53>
    if(ip->addrs[i]){
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7d:	83 c2 04             	add    $0x4,%edx
80101d80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d84:	85 c0                	test   %eax,%eax
80101d86:	74 2f                	je     80101db7 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8e:	83 c2 04             	add    $0x4,%edx
80101d91:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 00                	mov    (%eax),%eax
80101d9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d9e:	89 04 24             	mov    %eax,(%esp)
80101da1:	e8 1c f7 ff ff       	call   801014c2 <bfree>
      ip->addrs[i] = 0;
80101da6:	8b 45 08             	mov    0x8(%ebp),%eax
80101da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dac:	83 c2 04             	add    $0x4,%edx
80101daf:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db6:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101db7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dbb:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80101dbf:	7e b6                	jle    80101d77 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 40 44             	mov    0x44(%eax),%eax
80101dc7:	85 c0                	test   %eax,%eax
80101dc9:	0f 84 9d 00 00 00    	je     80101e6c <itrunc+0x104>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 50 44             	mov    0x44(%eax),%edx
80101dd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd8:	8b 00                	mov    (%eax),%eax
80101dda:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dde:	89 04 24             	mov    %eax,(%esp)
80101de1:	e8 c0 e3 ff ff       	call   801001a6 <bread>
80101de6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101de9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dec:	83 c0 18             	add    $0x18,%eax
80101def:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101df2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101df9:	eb 3b                	jmp    80101e36 <itrunc+0xce>
      if(a[j])
80101dfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dfe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e05:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e08:	01 d0                	add    %edx,%eax
80101e0a:	8b 00                	mov    (%eax),%eax
80101e0c:	85 c0                	test   %eax,%eax
80101e0e:	74 22                	je     80101e32 <itrunc+0xca>
        bfree(ip->dev, a[j]);
80101e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e1a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e1d:	01 d0                	add    %edx,%eax
80101e1f:	8b 10                	mov    (%eax),%edx
80101e21:	8b 45 08             	mov    0x8(%ebp),%eax
80101e24:	8b 00                	mov    (%eax),%eax
80101e26:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e2a:	89 04 24             	mov    %eax,(%esp)
80101e2d:	e8 90 f6 ff ff       	call   801014c2 <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e32:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e39:	3d ff 00 00 00       	cmp    $0xff,%eax
80101e3e:	76 bb                	jbe    80101dfb <itrunc+0x93>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e43:	89 04 24             	mov    %eax,(%esp)
80101e46:	e8 cc e3 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4e:	8b 50 44             	mov    0x44(%eax),%edx
80101e51:	8b 45 08             	mov    0x8(%ebp),%eax
80101e54:	8b 00                	mov    (%eax),%eax
80101e56:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e5a:	89 04 24             	mov    %eax,(%esp)
80101e5d:	e8 60 f6 ff ff       	call   801014c2 <bfree>
    ip->addrs[NDIRECT] = 0;
80101e62:	8b 45 08             	mov    0x8(%ebp),%eax
80101e65:	c7 40 44 00 00 00 00 	movl   $0x0,0x44(%eax)
  }

  ip->size = 0;
80101e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e76:	8b 45 08             	mov    0x8(%ebp),%eax
80101e79:	89 04 24             	mov    %eax,(%esp)
80101e7c:	e8 0a f8 ff ff       	call   8010168b <iupdate>
}
80101e81:	c9                   	leave  
80101e82:	c3                   	ret    

80101e83 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e83:	55                   	push   %ebp
80101e84:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e86:	8b 45 08             	mov    0x8(%ebp),%eax
80101e89:	8b 00                	mov    (%eax),%eax
80101e8b:	89 c2                	mov    %eax,%edx
80101e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e90:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	8b 50 04             	mov    0x4(%eax),%edx
80101e99:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9c:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea2:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea9:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb6:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	8b 50 18             	mov    0x18(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ec6:	5d                   	pop    %ebp
80101ec7:	c3                   	ret    

80101ec8 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ec8:	55                   	push   %ebp
80101ec9:	89 e5                	mov    %esp,%ebp
80101ecb:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ece:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ed5:	66 83 f8 03          	cmp    $0x3,%ax
80101ed9:	75 60                	jne    80101f3b <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101edb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ede:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee2:	66 85 c0             	test   %ax,%ax
80101ee5:	78 20                	js     80101f07 <readi+0x3f>
80101ee7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eea:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101eee:	66 83 f8 09          	cmp    $0x9,%ax
80101ef2:	7f 13                	jg     80101f07 <readi+0x3f>
80101ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efb:	98                   	cwtl   
80101efc:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80101f03:	85 c0                	test   %eax,%eax
80101f05:	75 0a                	jne    80101f11 <readi+0x49>
      return -1;
80101f07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f0c:	e9 19 01 00 00       	jmp    8010202a <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f18:	98                   	cwtl   
80101f19:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80101f20:	8b 55 14             	mov    0x14(%ebp),%edx
80101f23:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f27:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f2a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f2e:	8b 55 08             	mov    0x8(%ebp),%edx
80101f31:	89 14 24             	mov    %edx,(%esp)
80101f34:	ff d0                	call   *%eax
80101f36:	e9 ef 00 00 00       	jmp    8010202a <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	8b 40 18             	mov    0x18(%eax),%eax
80101f41:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f44:	72 0d                	jb     80101f53 <readi+0x8b>
80101f46:	8b 45 14             	mov    0x14(%ebp),%eax
80101f49:	8b 55 10             	mov    0x10(%ebp),%edx
80101f4c:	01 d0                	add    %edx,%eax
80101f4e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f51:	73 0a                	jae    80101f5d <readi+0x95>
    return -1;
80101f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f58:	e9 cd 00 00 00       	jmp    8010202a <readi+0x162>
  if(off + n > ip->size)
80101f5d:	8b 45 14             	mov    0x14(%ebp),%eax
80101f60:	8b 55 10             	mov    0x10(%ebp),%edx
80101f63:	01 c2                	add    %eax,%edx
80101f65:	8b 45 08             	mov    0x8(%ebp),%eax
80101f68:	8b 40 18             	mov    0x18(%eax),%eax
80101f6b:	39 c2                	cmp    %eax,%edx
80101f6d:	76 0c                	jbe    80101f7b <readi+0xb3>
    n = ip->size - off;
80101f6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f72:	8b 40 18             	mov    0x18(%eax),%eax
80101f75:	2b 45 10             	sub    0x10(%ebp),%eax
80101f78:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f7b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f82:	e9 94 00 00 00       	jmp    8010201b <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f87:	8b 45 10             	mov    0x10(%ebp),%eax
80101f8a:	c1 e8 09             	shr    $0x9,%eax
80101f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f91:	8b 45 08             	mov    0x8(%ebp),%eax
80101f94:	89 04 24             	mov    %eax,(%esp)
80101f97:	e8 4d fb ff ff       	call   80101ae9 <bmap>
80101f9c:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9f:	8b 12                	mov    (%edx),%edx
80101fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fa5:	89 14 24             	mov    %edx,(%esp)
80101fa8:	e8 f9 e1 ff ff       	call   801001a6 <bread>
80101fad:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fb0:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb3:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fb8:	89 c2                	mov    %eax,%edx
80101fba:	b8 00 02 00 00       	mov    $0x200,%eax
80101fbf:	29 d0                	sub    %edx,%eax
80101fc1:	89 c2                	mov    %eax,%edx
80101fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fc6:	8b 4d 14             	mov    0x14(%ebp),%ecx
80101fc9:	29 c1                	sub    %eax,%ecx
80101fcb:	89 c8                	mov    %ecx,%eax
80101fcd:	39 c2                	cmp    %eax,%edx
80101fcf:	0f 46 c2             	cmovbe %edx,%eax
80101fd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fd5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd8:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdd:	8d 50 10             	lea    0x10(%eax),%edx
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	01 d0                	add    %edx,%eax
80101fe5:	8d 50 08             	lea    0x8(%eax),%edx
80101fe8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101feb:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fef:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ff6:	89 04 24             	mov    %eax,(%esp)
80101ff9:	e8 42 33 00 00       	call   80105340 <memmove>
    brelse(bp);
80101ffe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102001:	89 04 24             	mov    %eax,(%esp)
80102004:	e8 0e e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102009:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200c:	01 45 f4             	add    %eax,-0xc(%ebp)
8010200f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102012:	01 45 10             	add    %eax,0x10(%ebp)
80102015:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102018:	01 45 0c             	add    %eax,0xc(%ebp)
8010201b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010201e:	3b 45 14             	cmp    0x14(%ebp),%eax
80102021:	0f 82 60 ff ff ff    	jb     80101f87 <readi+0xbf>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102027:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202a:	c9                   	leave  
8010202b:	c3                   	ret    

8010202c <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202c:	55                   	push   %ebp
8010202d:	89 e5                	mov    %esp,%ebp
8010202f:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102032:	8b 45 08             	mov    0x8(%ebp),%eax
80102035:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102039:	66 83 f8 03          	cmp    $0x3,%ax
8010203d:	75 60                	jne    8010209f <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102046:	66 85 c0             	test   %ax,%ax
80102049:	78 20                	js     8010206b <writei+0x3f>
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102052:	66 83 f8 09          	cmp    $0x9,%ax
80102056:	7f 13                	jg     8010206b <writei+0x3f>
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010205f:	98                   	cwtl   
80102060:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102067:	85 c0                	test   %eax,%eax
80102069:	75 0a                	jne    80102075 <writei+0x49>
      return -1;
8010206b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102070:	e9 44 01 00 00       	jmp    801021b9 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102075:	8b 45 08             	mov    0x8(%ebp),%eax
80102078:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207c:	98                   	cwtl   
8010207d:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80102084:	8b 55 14             	mov    0x14(%ebp),%edx
80102087:	89 54 24 08          	mov    %edx,0x8(%esp)
8010208b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010208e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102092:	8b 55 08             	mov    0x8(%ebp),%edx
80102095:	89 14 24             	mov    %edx,(%esp)
80102098:	ff d0                	call   *%eax
8010209a:	e9 1a 01 00 00       	jmp    801021b9 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	8b 40 18             	mov    0x18(%eax),%eax
801020a5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a8:	72 0d                	jb     801020b7 <writei+0x8b>
801020aa:	8b 45 14             	mov    0x14(%ebp),%eax
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	01 d0                	add    %edx,%eax
801020b2:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b5:	73 0a                	jae    801020c1 <writei+0x95>
    return -1;
801020b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bc:	e9 f8 00 00 00       	jmp    801021b9 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
801020c1:	8b 45 14             	mov    0x14(%ebp),%eax
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	01 d0                	add    %edx,%eax
801020c9:	3d 00 14 82 00       	cmp    $0x821400,%eax
801020ce:	76 0a                	jbe    801020da <writei+0xae>
    return -1;
801020d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d5:	e9 df 00 00 00       	jmp    801021b9 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e1:	e9 9f 00 00 00       	jmp    80102185 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e6:	8b 45 10             	mov    0x10(%ebp),%eax
801020e9:	c1 e8 09             	shr    $0x9,%eax
801020ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801020f0:	8b 45 08             	mov    0x8(%ebp),%eax
801020f3:	89 04 24             	mov    %eax,(%esp)
801020f6:	e8 ee f9 ff ff       	call   80101ae9 <bmap>
801020fb:	8b 55 08             	mov    0x8(%ebp),%edx
801020fe:	8b 12                	mov    (%edx),%edx
80102100:	89 44 24 04          	mov    %eax,0x4(%esp)
80102104:	89 14 24             	mov    %edx,(%esp)
80102107:	e8 9a e0 ff ff       	call   801001a6 <bread>
8010210c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010210f:	8b 45 10             	mov    0x10(%ebp),%eax
80102112:	25 ff 01 00 00       	and    $0x1ff,%eax
80102117:	89 c2                	mov    %eax,%edx
80102119:	b8 00 02 00 00       	mov    $0x200,%eax
8010211e:	29 d0                	sub    %edx,%eax
80102120:	89 c2                	mov    %eax,%edx
80102122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102125:	8b 4d 14             	mov    0x14(%ebp),%ecx
80102128:	29 c1                	sub    %eax,%ecx
8010212a:	89 c8                	mov    %ecx,%eax
8010212c:	39 c2                	cmp    %eax,%edx
8010212e:	0f 46 c2             	cmovbe %edx,%eax
80102131:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102134:	8b 45 10             	mov    0x10(%ebp),%eax
80102137:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213c:	8d 50 10             	lea    0x10(%eax),%edx
8010213f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102142:	01 d0                	add    %edx,%eax
80102144:	8d 50 08             	lea    0x8(%eax),%edx
80102147:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010214a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010214e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102151:	89 44 24 04          	mov    %eax,0x4(%esp)
80102155:	89 14 24             	mov    %edx,(%esp)
80102158:	e8 e3 31 00 00       	call   80105340 <memmove>
    log_write(bp);
8010215d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102160:	89 04 24             	mov    %eax,(%esp)
80102163:	e8 7e 12 00 00       	call   801033e6 <log_write>
    brelse(bp);
80102168:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010216b:	89 04 24             	mov    %eax,(%esp)
8010216e:	e8 a4 e0 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102173:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102176:	01 45 f4             	add    %eax,-0xc(%ebp)
80102179:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217c:	01 45 10             	add    %eax,0x10(%ebp)
8010217f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102182:	01 45 0c             	add    %eax,0xc(%ebp)
80102185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102188:	3b 45 14             	cmp    0x14(%ebp),%eax
8010218b:	0f 82 55 ff ff ff    	jb     801020e6 <writei+0xba>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102191:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102195:	74 1f                	je     801021b6 <writei+0x18a>
80102197:	8b 45 08             	mov    0x8(%ebp),%eax
8010219a:	8b 40 18             	mov    0x18(%eax),%eax
8010219d:	3b 45 10             	cmp    0x10(%ebp),%eax
801021a0:	73 14                	jae    801021b6 <writei+0x18a>
    ip->size = off;
801021a2:	8b 45 08             	mov    0x8(%ebp),%eax
801021a5:	8b 55 10             	mov    0x10(%ebp),%edx
801021a8:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021ab:	8b 45 08             	mov    0x8(%ebp),%eax
801021ae:	89 04 24             	mov    %eax,(%esp)
801021b1:	e8 d5 f4 ff ff       	call   8010168b <iupdate>
  }
  return n;
801021b6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b9:	c9                   	leave  
801021ba:	c3                   	ret    

801021bb <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021bb:	55                   	push   %ebp
801021bc:	89 e5                	mov    %esp,%ebp
801021be:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801021c1:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021c8:	00 
801021c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801021cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801021d0:	8b 45 08             	mov    0x8(%ebp),%eax
801021d3:	89 04 24             	mov    %eax,(%esp)
801021d6:	e8 08 32 00 00       	call   801053e3 <strncmp>
}
801021db:	c9                   	leave  
801021dc:	c3                   	ret    

801021dd <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021dd:	55                   	push   %ebp
801021de:	89 e5                	mov    %esp,%ebp
801021e0:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021e3:	8b 45 08             	mov    0x8(%ebp),%eax
801021e6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021ea:	66 83 f8 01          	cmp    $0x1,%ax
801021ee:	74 0c                	je     801021fc <dirlookup+0x1f>
    panic("dirlookup not DIR");
801021f0:	c7 04 24 69 89 10 80 	movl   $0x80108969,(%esp)
801021f7:	e8 3e e3 ff ff       	call   8010053a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102203:	e9 88 00 00 00       	jmp    80102290 <dirlookup+0xb3>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102208:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220f:	00 
80102210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102213:	89 44 24 08          	mov    %eax,0x8(%esp)
80102217:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221e:	8b 45 08             	mov    0x8(%ebp),%eax
80102221:	89 04 24             	mov    %eax,(%esp)
80102224:	e8 9f fc ff ff       	call   80101ec8 <readi>
80102229:	83 f8 10             	cmp    $0x10,%eax
8010222c:	74 0c                	je     8010223a <dirlookup+0x5d>
      panic("dirlink read");
8010222e:	c7 04 24 7b 89 10 80 	movl   $0x8010897b,(%esp)
80102235:	e8 00 e3 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
8010223a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223e:	66 85 c0             	test   %ax,%ax
80102241:	75 02                	jne    80102245 <dirlookup+0x68>
      continue;
80102243:	eb 47                	jmp    8010228c <dirlookup+0xaf>
    if(namecmp(name, de.name) == 0){
80102245:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102248:	83 c0 02             	add    $0x2,%eax
8010224b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010224f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102252:	89 04 24             	mov    %eax,(%esp)
80102255:	e8 61 ff ff ff       	call   801021bb <namecmp>
8010225a:	85 c0                	test   %eax,%eax
8010225c:	75 2e                	jne    8010228c <dirlookup+0xaf>
      // entry matches path element
      if(poff)
8010225e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102262:	74 08                	je     8010226c <dirlookup+0x8f>
        *poff = off;
80102264:	8b 45 10             	mov    0x10(%ebp),%eax
80102267:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010226a:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010226c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102270:	0f b7 c0             	movzwl %ax,%eax
80102273:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102276:	8b 45 08             	mov    0x8(%ebp),%eax
80102279:	8b 00                	mov    (%eax),%eax
8010227b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010227e:	89 54 24 04          	mov    %edx,0x4(%esp)
80102282:	89 04 24             	mov    %eax,(%esp)
80102285:	e8 b9 f4 ff ff       	call   80101743 <iget>
8010228a:	eb 18                	jmp    801022a4 <dirlookup+0xc7>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010228c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102290:	8b 45 08             	mov    0x8(%ebp),%eax
80102293:	8b 40 18             	mov    0x18(%eax),%eax
80102296:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102299:	0f 87 69 ff ff ff    	ja     80102208 <dirlookup+0x2b>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010229f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022a4:	c9                   	leave  
801022a5:	c3                   	ret    

801022a6 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022a6:	55                   	push   %ebp
801022a7:	89 e5                	mov    %esp,%ebp
801022a9:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801022b3:	00 
801022b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801022b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801022bb:	8b 45 08             	mov    0x8(%ebp),%eax
801022be:	89 04 24             	mov    %eax,(%esp)
801022c1:	e8 17 ff ff ff       	call   801021dd <dirlookup>
801022c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022cd:	74 15                	je     801022e4 <dirlink+0x3e>
    iput(ip);
801022cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022d2:	89 04 24             	mov    %eax,(%esp)
801022d5:	e8 20 f7 ff ff       	call   801019fa <iput>
    return -1;
801022da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022df:	e9 b7 00 00 00       	jmp    8010239b <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022eb:	eb 46                	jmp    80102333 <dirlink+0x8d>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022f7:	00 
801022f8:	89 44 24 08          	mov    %eax,0x8(%esp)
801022fc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ff:	89 44 24 04          	mov    %eax,0x4(%esp)
80102303:	8b 45 08             	mov    0x8(%ebp),%eax
80102306:	89 04 24             	mov    %eax,(%esp)
80102309:	e8 ba fb ff ff       	call   80101ec8 <readi>
8010230e:	83 f8 10             	cmp    $0x10,%eax
80102311:	74 0c                	je     8010231f <dirlink+0x79>
      panic("dirlink read");
80102313:	c7 04 24 7b 89 10 80 	movl   $0x8010897b,(%esp)
8010231a:	e8 1b e2 ff ff       	call   8010053a <panic>
    if(de.inum == 0)
8010231f:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102323:	66 85 c0             	test   %ax,%ax
80102326:	75 02                	jne    8010232a <dirlink+0x84>
      break;
80102328:	eb 16                	jmp    80102340 <dirlink+0x9a>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010232a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232d:	83 c0 10             	add    $0x10,%eax
80102330:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102333:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102336:	8b 45 08             	mov    0x8(%ebp),%eax
80102339:	8b 40 18             	mov    0x18(%eax),%eax
8010233c:	39 c2                	cmp    %eax,%edx
8010233e:	72 ad                	jb     801022ed <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102340:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102347:	00 
80102348:	8b 45 0c             	mov    0xc(%ebp),%eax
8010234b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010234f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102352:	83 c0 02             	add    $0x2,%eax
80102355:	89 04 24             	mov    %eax,(%esp)
80102358:	e8 dc 30 00 00       	call   80105439 <strncpy>
  de.inum = inum;
8010235d:	8b 45 10             	mov    0x10(%ebp),%eax
80102360:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102367:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010236e:	00 
8010236f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102373:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102376:	89 44 24 04          	mov    %eax,0x4(%esp)
8010237a:	8b 45 08             	mov    0x8(%ebp),%eax
8010237d:	89 04 24             	mov    %eax,(%esp)
80102380:	e8 a7 fc ff ff       	call   8010202c <writei>
80102385:	83 f8 10             	cmp    $0x10,%eax
80102388:	74 0c                	je     80102396 <dirlink+0xf0>
    panic("dirlink");
8010238a:	c7 04 24 88 89 10 80 	movl   $0x80108988,(%esp)
80102391:	e8 a4 e1 ff ff       	call   8010053a <panic>
  
  return 0;
80102396:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010239b:	c9                   	leave  
8010239c:	c3                   	ret    

8010239d <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010239d:	55                   	push   %ebp
8010239e:	89 e5                	mov    %esp,%ebp
801023a0:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801023a3:	eb 04                	jmp    801023a9 <skipelem+0xc>
    path++;
801023a5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801023a9:	8b 45 08             	mov    0x8(%ebp),%eax
801023ac:	0f b6 00             	movzbl (%eax),%eax
801023af:	3c 2f                	cmp    $0x2f,%al
801023b1:	74 f2                	je     801023a5 <skipelem+0x8>
    path++;
  if(*path == 0)
801023b3:	8b 45 08             	mov    0x8(%ebp),%eax
801023b6:	0f b6 00             	movzbl (%eax),%eax
801023b9:	84 c0                	test   %al,%al
801023bb:	75 0a                	jne    801023c7 <skipelem+0x2a>
    return 0;
801023bd:	b8 00 00 00 00       	mov    $0x0,%eax
801023c2:	e9 86 00 00 00       	jmp    8010244d <skipelem+0xb0>
  s = path;
801023c7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023cd:	eb 04                	jmp    801023d3 <skipelem+0x36>
    path++;
801023cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023d3:	8b 45 08             	mov    0x8(%ebp),%eax
801023d6:	0f b6 00             	movzbl (%eax),%eax
801023d9:	3c 2f                	cmp    $0x2f,%al
801023db:	74 0a                	je     801023e7 <skipelem+0x4a>
801023dd:	8b 45 08             	mov    0x8(%ebp),%eax
801023e0:	0f b6 00             	movzbl (%eax),%eax
801023e3:	84 c0                	test   %al,%al
801023e5:	75 e8                	jne    801023cf <skipelem+0x32>
    path++;
  len = path - s;
801023e7:	8b 55 08             	mov    0x8(%ebp),%edx
801023ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023ed:	29 c2                	sub    %eax,%edx
801023ef:	89 d0                	mov    %edx,%eax
801023f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023f4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023f8:	7e 1c                	jle    80102416 <skipelem+0x79>
    memmove(name, s, DIRSIZ);
801023fa:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102401:	00 
80102402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102405:	89 44 24 04          	mov    %eax,0x4(%esp)
80102409:	8b 45 0c             	mov    0xc(%ebp),%eax
8010240c:	89 04 24             	mov    %eax,(%esp)
8010240f:	e8 2c 2f 00 00       	call   80105340 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102414:	eb 2a                	jmp    80102440 <skipelem+0xa3>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102419:	89 44 24 08          	mov    %eax,0x8(%esp)
8010241d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102420:	89 44 24 04          	mov    %eax,0x4(%esp)
80102424:	8b 45 0c             	mov    0xc(%ebp),%eax
80102427:	89 04 24             	mov    %eax,(%esp)
8010242a:	e8 11 2f 00 00       	call   80105340 <memmove>
    name[len] = 0;
8010242f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102432:	8b 45 0c             	mov    0xc(%ebp),%eax
80102435:	01 d0                	add    %edx,%eax
80102437:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010243a:	eb 04                	jmp    80102440 <skipelem+0xa3>
    path++;
8010243c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102440:	8b 45 08             	mov    0x8(%ebp),%eax
80102443:	0f b6 00             	movzbl (%eax),%eax
80102446:	3c 2f                	cmp    $0x2f,%al
80102448:	74 f2                	je     8010243c <skipelem+0x9f>
    path++;
  return path;
8010244a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010244d:	c9                   	leave  
8010244e:	c3                   	ret    

8010244f <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010244f:	55                   	push   %ebp
80102450:	89 e5                	mov    %esp,%ebp
80102452:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102455:	8b 45 08             	mov    0x8(%ebp),%eax
80102458:	0f b6 00             	movzbl (%eax),%eax
8010245b:	3c 2f                	cmp    $0x2f,%al
8010245d:	75 1c                	jne    8010247b <namex+0x2c>
    ip = iget(ROOTDEV, ROOTINO);
8010245f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102466:	00 
80102467:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010246e:	e8 d0 f2 ff ff       	call   80101743 <iget>
80102473:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102476:	e9 af 00 00 00       	jmp    8010252a <namex+0xdb>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
8010247b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102481:	8b 40 68             	mov    0x68(%eax),%eax
80102484:	89 04 24             	mov    %eax,(%esp)
80102487:	e8 89 f3 ff ff       	call   80101815 <idup>
8010248c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010248f:	e9 96 00 00 00       	jmp    8010252a <namex+0xdb>
    ilock(ip);
80102494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102497:	89 04 24             	mov    %eax,(%esp)
8010249a:	e8 a8 f3 ff ff       	call   80101847 <ilock>
    if(ip->type != T_DIR){
8010249f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801024a6:	66 83 f8 01          	cmp    $0x1,%ax
801024aa:	74 15                	je     801024c1 <namex+0x72>
      iunlockput(ip);
801024ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024af:	89 04 24             	mov    %eax,(%esp)
801024b2:	e8 14 f6 ff ff       	call   80101acb <iunlockput>
      return 0;
801024b7:	b8 00 00 00 00       	mov    $0x0,%eax
801024bc:	e9 a3 00 00 00       	jmp    80102564 <namex+0x115>
    }
    if(nameiparent && *path == '\0'){
801024c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024c5:	74 1d                	je     801024e4 <namex+0x95>
801024c7:	8b 45 08             	mov    0x8(%ebp),%eax
801024ca:	0f b6 00             	movzbl (%eax),%eax
801024cd:	84 c0                	test   %al,%al
801024cf:	75 13                	jne    801024e4 <namex+0x95>
      // Stop one level early.
      iunlock(ip);
801024d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024d4:	89 04 24             	mov    %eax,(%esp)
801024d7:	e8 b9 f4 ff ff       	call   80101995 <iunlock>
      return ip;
801024dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024df:	e9 80 00 00 00       	jmp    80102564 <namex+0x115>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024eb:	00 
801024ec:	8b 45 10             	mov    0x10(%ebp),%eax
801024ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801024f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f6:	89 04 24             	mov    %eax,(%esp)
801024f9:	e8 df fc ff ff       	call   801021dd <dirlookup>
801024fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102501:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102505:	75 12                	jne    80102519 <namex+0xca>
      iunlockput(ip);
80102507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250a:	89 04 24             	mov    %eax,(%esp)
8010250d:	e8 b9 f5 ff ff       	call   80101acb <iunlockput>
      return 0;
80102512:	b8 00 00 00 00       	mov    $0x0,%eax
80102517:	eb 4b                	jmp    80102564 <namex+0x115>
    }
    iunlockput(ip);
80102519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010251c:	89 04 24             	mov    %eax,(%esp)
8010251f:	e8 a7 f5 ff ff       	call   80101acb <iunlockput>
    ip = next;
80102524:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102527:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010252a:	8b 45 10             	mov    0x10(%ebp),%eax
8010252d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102531:	8b 45 08             	mov    0x8(%ebp),%eax
80102534:	89 04 24             	mov    %eax,(%esp)
80102537:	e8 61 fe ff ff       	call   8010239d <skipelem>
8010253c:	89 45 08             	mov    %eax,0x8(%ebp)
8010253f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102543:	0f 85 4b ff ff ff    	jne    80102494 <namex+0x45>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102549:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010254d:	74 12                	je     80102561 <namex+0x112>
    iput(ip);
8010254f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102552:	89 04 24             	mov    %eax,(%esp)
80102555:	e8 a0 f4 ff ff       	call   801019fa <iput>
    return 0;
8010255a:	b8 00 00 00 00       	mov    $0x0,%eax
8010255f:	eb 03                	jmp    80102564 <namex+0x115>
  }
  return ip;
80102561:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102564:	c9                   	leave  
80102565:	c3                   	ret    

80102566 <namei>:

struct inode*
namei(char *path)
{
80102566:	55                   	push   %ebp
80102567:	89 e5                	mov    %esp,%ebp
80102569:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010256c:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010256f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102573:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010257a:	00 
8010257b:	8b 45 08             	mov    0x8(%ebp),%eax
8010257e:	89 04 24             	mov    %eax,(%esp)
80102581:	e8 c9 fe ff ff       	call   8010244f <namex>
}
80102586:	c9                   	leave  
80102587:	c3                   	ret    

80102588 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102588:	55                   	push   %ebp
80102589:	89 e5                	mov    %esp,%ebp
8010258b:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
8010258e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102591:	89 44 24 08          	mov    %eax,0x8(%esp)
80102595:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010259c:	00 
8010259d:	8b 45 08             	mov    0x8(%ebp),%eax
801025a0:	89 04 24             	mov    %eax,(%esp)
801025a3:	e8 a7 fe ff ff       	call   8010244f <namex>
}
801025a8:	c9                   	leave  
801025a9:	c3                   	ret    

801025aa <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801025aa:	55                   	push   %ebp
801025ab:	89 e5                	mov    %esp,%ebp
801025ad:	83 ec 14             	sub    $0x14,%esp
801025b0:	8b 45 08             	mov    0x8(%ebp),%eax
801025b3:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025b7:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801025bb:	89 c2                	mov    %eax,%edx
801025bd:	ec                   	in     (%dx),%al
801025be:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801025c1:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801025c5:	c9                   	leave  
801025c6:	c3                   	ret    

801025c7 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801025c7:	55                   	push   %ebp
801025c8:	89 e5                	mov    %esp,%ebp
801025ca:	57                   	push   %edi
801025cb:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025cc:	8b 55 08             	mov    0x8(%ebp),%edx
801025cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025d2:	8b 45 10             	mov    0x10(%ebp),%eax
801025d5:	89 cb                	mov    %ecx,%ebx
801025d7:	89 df                	mov    %ebx,%edi
801025d9:	89 c1                	mov    %eax,%ecx
801025db:	fc                   	cld    
801025dc:	f3 6d                	rep insl (%dx),%es:(%edi)
801025de:	89 c8                	mov    %ecx,%eax
801025e0:	89 fb                	mov    %edi,%ebx
801025e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025e5:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025e8:	5b                   	pop    %ebx
801025e9:	5f                   	pop    %edi
801025ea:	5d                   	pop    %ebp
801025eb:	c3                   	ret    

801025ec <outb>:

static inline void
outb(ushort port, uchar data)
{
801025ec:	55                   	push   %ebp
801025ed:	89 e5                	mov    %esp,%ebp
801025ef:	83 ec 08             	sub    $0x8,%esp
801025f2:	8b 55 08             	mov    0x8(%ebp),%edx
801025f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801025f8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025fc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025ff:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102603:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102607:	ee                   	out    %al,(%dx)
}
80102608:	c9                   	leave  
80102609:	c3                   	ret    

8010260a <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010260a:	55                   	push   %ebp
8010260b:	89 e5                	mov    %esp,%ebp
8010260d:	56                   	push   %esi
8010260e:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010260f:	8b 55 08             	mov    0x8(%ebp),%edx
80102612:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102615:	8b 45 10             	mov    0x10(%ebp),%eax
80102618:	89 cb                	mov    %ecx,%ebx
8010261a:	89 de                	mov    %ebx,%esi
8010261c:	89 c1                	mov    %eax,%ecx
8010261e:	fc                   	cld    
8010261f:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102621:	89 c8                	mov    %ecx,%eax
80102623:	89 f3                	mov    %esi,%ebx
80102625:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102628:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010262b:	5b                   	pop    %ebx
8010262c:	5e                   	pop    %esi
8010262d:	5d                   	pop    %ebp
8010262e:	c3                   	ret    

8010262f <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010262f:	55                   	push   %ebp
80102630:	89 e5                	mov    %esp,%ebp
80102632:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102635:	90                   	nop
80102636:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010263d:	e8 68 ff ff ff       	call   801025aa <inb>
80102642:	0f b6 c0             	movzbl %al,%eax
80102645:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102648:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010264b:	25 c0 00 00 00       	and    $0xc0,%eax
80102650:	83 f8 40             	cmp    $0x40,%eax
80102653:	75 e1                	jne    80102636 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102655:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102659:	74 11                	je     8010266c <idewait+0x3d>
8010265b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010265e:	83 e0 21             	and    $0x21,%eax
80102661:	85 c0                	test   %eax,%eax
80102663:	74 07                	je     8010266c <idewait+0x3d>
    return -1;
80102665:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010266a:	eb 05                	jmp    80102671 <idewait+0x42>
  return 0;
8010266c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102671:	c9                   	leave  
80102672:	c3                   	ret    

80102673 <ideinit>:

void
ideinit(void)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
80102679:	c7 44 24 04 90 89 10 	movl   $0x80108990,0x4(%esp)
80102680:	80 
80102681:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102688:	e8 6f 29 00 00       	call   80104ffc <initlock>
  picenable(IRQ_IDE);
8010268d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102694:	e8 29 15 00 00       	call   80103bc2 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102699:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
8010269e:	83 e8 01             	sub    $0x1,%eax
801026a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801026a5:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801026ac:	e8 0c 04 00 00       	call   80102abd <ioapicenable>
  idewait(0);
801026b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801026b8:	e8 72 ff ff ff       	call   8010262f <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801026bd:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801026c4:	00 
801026c5:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026cc:	e8 1b ff ff ff       	call   801025ec <outb>
  for(i=0; i<1000; i++){
801026d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026d8:	eb 20                	jmp    801026fa <ideinit+0x87>
    if(inb(0x1f7) != 0){
801026da:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026e1:	e8 c4 fe ff ff       	call   801025aa <inb>
801026e6:	84 c0                	test   %al,%al
801026e8:	74 0c                	je     801026f6 <ideinit+0x83>
      havedisk1 = 1;
801026ea:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
801026f1:	00 00 00 
      break;
801026f4:	eb 0d                	jmp    80102703 <ideinit+0x90>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026fa:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102701:	7e d7                	jle    801026da <ideinit+0x67>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102703:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
8010270a:	00 
8010270b:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102712:	e8 d5 fe ff ff       	call   801025ec <outb>
}
80102717:	c9                   	leave  
80102718:	c3                   	ret    

80102719 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102719:	55                   	push   %ebp
8010271a:	89 e5                	mov    %esp,%ebp
8010271c:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010271f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102723:	75 0c                	jne    80102731 <idestart+0x18>
    panic("idestart");
80102725:	c7 04 24 94 89 10 80 	movl   $0x80108994,(%esp)
8010272c:	e8 09 de ff ff       	call   8010053a <panic>

  idewait(0);
80102731:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102738:	e8 f2 fe ff ff       	call   8010262f <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010273d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102744:	00 
80102745:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010274c:	e8 9b fe ff ff       	call   801025ec <outb>
  outb(0x1f2, 1);  // number of sectors
80102751:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102758:	00 
80102759:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102760:	e8 87 fe ff ff       	call   801025ec <outb>
  outb(0x1f3, b->sector & 0xff);
80102765:	8b 45 08             	mov    0x8(%ebp),%eax
80102768:	8b 40 08             	mov    0x8(%eax),%eax
8010276b:	0f b6 c0             	movzbl %al,%eax
8010276e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102772:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102779:	e8 6e fe ff ff       	call   801025ec <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
8010277e:	8b 45 08             	mov    0x8(%ebp),%eax
80102781:	8b 40 08             	mov    0x8(%eax),%eax
80102784:	c1 e8 08             	shr    $0x8,%eax
80102787:	0f b6 c0             	movzbl %al,%eax
8010278a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010278e:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102795:	e8 52 fe ff ff       	call   801025ec <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
8010279a:	8b 45 08             	mov    0x8(%ebp),%eax
8010279d:	8b 40 08             	mov    0x8(%eax),%eax
801027a0:	c1 e8 10             	shr    $0x10,%eax
801027a3:	0f b6 c0             	movzbl %al,%eax
801027a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801027aa:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801027b1:	e8 36 fe ff ff       	call   801025ec <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
801027b6:	8b 45 08             	mov    0x8(%ebp),%eax
801027b9:	8b 40 04             	mov    0x4(%eax),%eax
801027bc:	83 e0 01             	and    $0x1,%eax
801027bf:	c1 e0 04             	shl    $0x4,%eax
801027c2:	89 c2                	mov    %eax,%edx
801027c4:	8b 45 08             	mov    0x8(%ebp),%eax
801027c7:	8b 40 08             	mov    0x8(%eax),%eax
801027ca:	c1 e8 18             	shr    $0x18,%eax
801027cd:	83 e0 0f             	and    $0xf,%eax
801027d0:	09 d0                	or     %edx,%eax
801027d2:	83 c8 e0             	or     $0xffffffe0,%eax
801027d5:	0f b6 c0             	movzbl %al,%eax
801027d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801027dc:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027e3:	e8 04 fe ff ff       	call   801025ec <outb>
  if(b->flags & B_DIRTY){
801027e8:	8b 45 08             	mov    0x8(%ebp),%eax
801027eb:	8b 00                	mov    (%eax),%eax
801027ed:	83 e0 04             	and    $0x4,%eax
801027f0:	85 c0                	test   %eax,%eax
801027f2:	74 34                	je     80102828 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
801027f4:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801027fb:	00 
801027fc:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102803:	e8 e4 fd ff ff       	call   801025ec <outb>
    outsl(0x1f0, b->data, 512/4);
80102808:	8b 45 08             	mov    0x8(%ebp),%eax
8010280b:	83 c0 18             	add    $0x18,%eax
8010280e:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102815:	00 
80102816:	89 44 24 04          	mov    %eax,0x4(%esp)
8010281a:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102821:	e8 e4 fd ff ff       	call   8010260a <outsl>
80102826:	eb 14                	jmp    8010283c <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102828:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
8010282f:	00 
80102830:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102837:	e8 b0 fd ff ff       	call   801025ec <outb>
  }
}
8010283c:	c9                   	leave  
8010283d:	c3                   	ret    

8010283e <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010283e:	55                   	push   %ebp
8010283f:	89 e5                	mov    %esp,%ebp
80102841:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102844:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
8010284b:	e8 cd 27 00 00       	call   8010501d <acquire>
  if((b = idequeue) == 0){
80102850:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102855:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102858:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010285c:	75 11                	jne    8010286f <ideintr+0x31>
    release(&idelock);
8010285e:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102865:	e8 15 28 00 00       	call   8010507f <release>
    // cprintf("spurious IDE interrupt\n");
    return;
8010286a:	e9 90 00 00 00       	jmp    801028ff <ideintr+0xc1>
  }
  idequeue = b->qnext;
8010286f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102872:	8b 40 14             	mov    0x14(%eax),%eax
80102875:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010287a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287d:	8b 00                	mov    (%eax),%eax
8010287f:	83 e0 04             	and    $0x4,%eax
80102882:	85 c0                	test   %eax,%eax
80102884:	75 2e                	jne    801028b4 <ideintr+0x76>
80102886:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010288d:	e8 9d fd ff ff       	call   8010262f <idewait>
80102892:	85 c0                	test   %eax,%eax
80102894:	78 1e                	js     801028b4 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
80102896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102899:	83 c0 18             	add    $0x18,%eax
8010289c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801028a3:	00 
801028a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801028a8:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801028af:	e8 13 fd ff ff       	call   801025c7 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b7:	8b 00                	mov    (%eax),%eax
801028b9:	83 c8 02             	or     $0x2,%eax
801028bc:	89 c2                	mov    %eax,%edx
801028be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c1:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c6:	8b 00                	mov    (%eax),%eax
801028c8:	83 e0 fb             	and    $0xfffffffb,%eax
801028cb:	89 c2                	mov    %eax,%edx
801028cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d0:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d5:	89 04 24             	mov    %eax,(%esp)
801028d8:	e8 9a 21 00 00       	call   80104a77 <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028dd:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028e2:	85 c0                	test   %eax,%eax
801028e4:	74 0d                	je     801028f3 <ideintr+0xb5>
    idestart(idequeue);
801028e6:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801028eb:	89 04 24             	mov    %eax,(%esp)
801028ee:	e8 26 fe ff ff       	call   80102719 <idestart>

  release(&idelock);
801028f3:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801028fa:	e8 80 27 00 00       	call   8010507f <release>
}
801028ff:	c9                   	leave  
80102900:	c3                   	ret    

80102901 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102901:	55                   	push   %ebp
80102902:	89 e5                	mov    %esp,%ebp
80102904:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102907:	8b 45 08             	mov    0x8(%ebp),%eax
8010290a:	8b 00                	mov    (%eax),%eax
8010290c:	83 e0 01             	and    $0x1,%eax
8010290f:	85 c0                	test   %eax,%eax
80102911:	75 0c                	jne    8010291f <iderw+0x1e>
    panic("iderw: buf not busy");
80102913:	c7 04 24 9d 89 10 80 	movl   $0x8010899d,(%esp)
8010291a:	e8 1b dc ff ff       	call   8010053a <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010291f:	8b 45 08             	mov    0x8(%ebp),%eax
80102922:	8b 00                	mov    (%eax),%eax
80102924:	83 e0 06             	and    $0x6,%eax
80102927:	83 f8 02             	cmp    $0x2,%eax
8010292a:	75 0c                	jne    80102938 <iderw+0x37>
    panic("iderw: nothing to do");
8010292c:	c7 04 24 b1 89 10 80 	movl   $0x801089b1,(%esp)
80102933:	e8 02 dc ff ff       	call   8010053a <panic>
  if(b->dev != 0 && !havedisk1)
80102938:	8b 45 08             	mov    0x8(%ebp),%eax
8010293b:	8b 40 04             	mov    0x4(%eax),%eax
8010293e:	85 c0                	test   %eax,%eax
80102940:	74 15                	je     80102957 <iderw+0x56>
80102942:	a1 58 b6 10 80       	mov    0x8010b658,%eax
80102947:	85 c0                	test   %eax,%eax
80102949:	75 0c                	jne    80102957 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
8010294b:	c7 04 24 c6 89 10 80 	movl   $0x801089c6,(%esp)
80102952:	e8 e3 db ff ff       	call   8010053a <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102957:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
8010295e:	e8 ba 26 00 00       	call   8010501d <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102963:	8b 45 08             	mov    0x8(%ebp),%eax
80102966:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010296d:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
80102974:	eb 0b                	jmp    80102981 <iderw+0x80>
80102976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102979:	8b 00                	mov    (%eax),%eax
8010297b:	83 c0 14             	add    $0x14,%eax
8010297e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102984:	8b 00                	mov    (%eax),%eax
80102986:	85 c0                	test   %eax,%eax
80102988:	75 ec                	jne    80102976 <iderw+0x75>
    ;
  *pp = b;
8010298a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298d:	8b 55 08             	mov    0x8(%ebp),%edx
80102990:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102992:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102997:	3b 45 08             	cmp    0x8(%ebp),%eax
8010299a:	75 0d                	jne    801029a9 <iderw+0xa8>
    idestart(b);
8010299c:	8b 45 08             	mov    0x8(%ebp),%eax
8010299f:	89 04 24             	mov    %eax,(%esp)
801029a2:	e8 72 fd ff ff       	call   80102719 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029a7:	eb 15                	jmp    801029be <iderw+0xbd>
801029a9:	eb 13                	jmp    801029be <iderw+0xbd>
    sleep(b, &idelock);
801029ab:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
801029b2:	80 
801029b3:	8b 45 08             	mov    0x8(%ebp),%eax
801029b6:	89 04 24             	mov    %eax,(%esp)
801029b9:	e8 dd 1f 00 00       	call   8010499b <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029be:	8b 45 08             	mov    0x8(%ebp),%eax
801029c1:	8b 00                	mov    (%eax),%eax
801029c3:	83 e0 06             	and    $0x6,%eax
801029c6:	83 f8 02             	cmp    $0x2,%eax
801029c9:	75 e0                	jne    801029ab <iderw+0xaa>
    sleep(b, &idelock);
  }

  release(&idelock);
801029cb:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801029d2:	e8 a8 26 00 00       	call   8010507f <release>
}
801029d7:	c9                   	leave  
801029d8:	c3                   	ret    

801029d9 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029d9:	55                   	push   %ebp
801029da:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029dc:	a1 54 f8 10 80       	mov    0x8010f854,%eax
801029e1:	8b 55 08             	mov    0x8(%ebp),%edx
801029e4:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029e6:	a1 54 f8 10 80       	mov    0x8010f854,%eax
801029eb:	8b 40 10             	mov    0x10(%eax),%eax
}
801029ee:	5d                   	pop    %ebp
801029ef:	c3                   	ret    

801029f0 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029f0:	55                   	push   %ebp
801029f1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f3:	a1 54 f8 10 80       	mov    0x8010f854,%eax
801029f8:	8b 55 08             	mov    0x8(%ebp),%edx
801029fb:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029fd:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102a02:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a05:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a08:	5d                   	pop    %ebp
80102a09:	c3                   	ret    

80102a0a <ioapicinit>:

void
ioapicinit(void)
{
80102a0a:	55                   	push   %ebp
80102a0b:	89 e5                	mov    %esp,%ebp
80102a0d:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
80102a10:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102a15:	85 c0                	test   %eax,%eax
80102a17:	75 05                	jne    80102a1e <ioapicinit+0x14>
    return;
80102a19:	e9 9d 00 00 00       	jmp    80102abb <ioapicinit+0xb1>

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a1e:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102a25:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a28:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a2f:	e8 a5 ff ff ff       	call   801029d9 <ioapicread>
80102a34:	c1 e8 10             	shr    $0x10,%eax
80102a37:	25 ff 00 00 00       	and    $0xff,%eax
80102a3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102a46:	e8 8e ff ff ff       	call   801029d9 <ioapicread>
80102a4b:	c1 e8 18             	shr    $0x18,%eax
80102a4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a51:	0f b6 05 20 f9 10 80 	movzbl 0x8010f920,%eax
80102a58:	0f b6 c0             	movzbl %al,%eax
80102a5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a5e:	74 0c                	je     80102a6c <ioapicinit+0x62>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a60:	c7 04 24 e4 89 10 80 	movl   $0x801089e4,(%esp)
80102a67:	e8 34 d9 ff ff       	call   801003a0 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a73:	eb 3e                	jmp    80102ab3 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a78:	83 c0 20             	add    $0x20,%eax
80102a7b:	0d 00 00 01 00       	or     $0x10000,%eax
80102a80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a83:	83 c2 08             	add    $0x8,%edx
80102a86:	01 d2                	add    %edx,%edx
80102a88:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a8c:	89 14 24             	mov    %edx,(%esp)
80102a8f:	e8 5c ff ff ff       	call   801029f0 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a97:	83 c0 08             	add    $0x8,%eax
80102a9a:	01 c0                	add    %eax,%eax
80102a9c:	83 c0 01             	add    $0x1,%eax
80102a9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102aa6:	00 
80102aa7:	89 04 24             	mov    %eax,(%esp)
80102aaa:	e8 41 ff ff ff       	call   801029f0 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102aaf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ab9:	7e ba                	jle    80102a75 <ioapicinit+0x6b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102abb:	c9                   	leave  
80102abc:	c3                   	ret    

80102abd <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102abd:	55                   	push   %ebp
80102abe:	89 e5                	mov    %esp,%ebp
80102ac0:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
80102ac3:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102ac8:	85 c0                	test   %eax,%eax
80102aca:	75 02                	jne    80102ace <ioapicenable+0x11>
    return;
80102acc:	eb 37                	jmp    80102b05 <ioapicenable+0x48>

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ace:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad1:	83 c0 20             	add    $0x20,%eax
80102ad4:	8b 55 08             	mov    0x8(%ebp),%edx
80102ad7:	83 c2 08             	add    $0x8,%edx
80102ada:	01 d2                	add    %edx,%edx
80102adc:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ae0:	89 14 24             	mov    %edx,(%esp)
80102ae3:	e8 08 ff ff ff       	call   801029f0 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
80102aeb:	c1 e0 18             	shl    $0x18,%eax
80102aee:	8b 55 08             	mov    0x8(%ebp),%edx
80102af1:	83 c2 08             	add    $0x8,%edx
80102af4:	01 d2                	add    %edx,%edx
80102af6:	83 c2 01             	add    $0x1,%edx
80102af9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102afd:	89 14 24             	mov    %edx,(%esp)
80102b00:	e8 eb fe ff ff       	call   801029f0 <ioapicwrite>
}
80102b05:	c9                   	leave  
80102b06:	c3                   	ret    

80102b07 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b07:	55                   	push   %ebp
80102b08:	89 e5                	mov    %esp,%ebp
80102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0d:	05 00 00 00 80       	add    $0x80000000,%eax
80102b12:	5d                   	pop    %ebp
80102b13:	c3                   	ret    

80102b14 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
80102b17:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102b1a:	c7 44 24 04 16 8a 10 	movl   $0x80108a16,0x4(%esp)
80102b21:	80 
80102b22:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102b29:	e8 ce 24 00 00       	call   80104ffc <initlock>
  kmem.use_lock = 0;
80102b2e:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102b35:	00 00 00 
  freerange(vstart, vend);
80102b38:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b3f:	8b 45 08             	mov    0x8(%ebp),%eax
80102b42:	89 04 24             	mov    %eax,(%esp)
80102b45:	e8 26 00 00 00       	call   80102b70 <freerange>
}
80102b4a:	c9                   	leave  
80102b4b:	c3                   	ret    

80102b4c <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102b52:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b55:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b59:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5c:	89 04 24             	mov    %eax,(%esp)
80102b5f:	e8 0c 00 00 00       	call   80102b70 <freerange>
  kmem.use_lock = 1;
80102b64:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
80102b6b:	00 00 00 
}
80102b6e:	c9                   	leave  
80102b6f:	c3                   	ret    

80102b70 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b70:	55                   	push   %ebp
80102b71:	89 e5                	mov    %esp,%ebp
80102b73:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b76:	8b 45 08             	mov    0x8(%ebp),%eax
80102b79:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b86:	eb 12                	jmp    80102b9a <freerange+0x2a>
    kfree(p);
80102b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b8b:	89 04 24             	mov    %eax,(%esp)
80102b8e:	e8 16 00 00 00       	call   80102ba9 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b93:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9d:	05 00 10 00 00       	add    $0x1000,%eax
80102ba2:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102ba5:	76 e1                	jbe    80102b88 <freerange+0x18>
    kfree(p);
}
80102ba7:	c9                   	leave  
80102ba8:	c3                   	ret    

80102ba9 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102ba9:	55                   	push   %ebp
80102baa:	89 e5                	mov    %esp,%ebp
80102bac:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102baf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb2:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bb7:	85 c0                	test   %eax,%eax
80102bb9:	75 1b                	jne    80102bd6 <kfree+0x2d>
80102bbb:	81 7d 08 3c 94 11 80 	cmpl   $0x8011943c,0x8(%ebp)
80102bc2:	72 12                	jb     80102bd6 <kfree+0x2d>
80102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc7:	89 04 24             	mov    %eax,(%esp)
80102bca:	e8 38 ff ff ff       	call   80102b07 <v2p>
80102bcf:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bd4:	76 0c                	jbe    80102be2 <kfree+0x39>
    panic("kfree");
80102bd6:	c7 04 24 1b 8a 10 80 	movl   $0x80108a1b,(%esp)
80102bdd:	e8 58 d9 ff ff       	call   8010053a <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102be2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102be9:	00 
80102bea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102bf1:	00 
80102bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf5:	89 04 24             	mov    %eax,(%esp)
80102bf8:	e8 74 26 00 00       	call   80105271 <memset>

  if(kmem.use_lock)
80102bfd:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102c02:	85 c0                	test   %eax,%eax
80102c04:	74 0c                	je     80102c12 <kfree+0x69>
    acquire(&kmem.lock);
80102c06:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102c0d:	e8 0b 24 00 00       	call   8010501d <acquire>
  r = (struct run*)v;
80102c12:	8b 45 08             	mov    0x8(%ebp),%eax
80102c15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c18:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c21:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c26:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102c2b:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102c30:	85 c0                	test   %eax,%eax
80102c32:	74 0c                	je     80102c40 <kfree+0x97>
    release(&kmem.lock);
80102c34:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102c3b:	e8 3f 24 00 00       	call   8010507f <release>
}
80102c40:	c9                   	leave  
80102c41:	c3                   	ret    

80102c42 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c42:	55                   	push   %ebp
80102c43:	89 e5                	mov    %esp,%ebp
80102c45:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102c48:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102c4d:	85 c0                	test   %eax,%eax
80102c4f:	74 0c                	je     80102c5d <kalloc+0x1b>
    acquire(&kmem.lock);
80102c51:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102c58:	e8 c0 23 00 00       	call   8010501d <acquire>
  r = kmem.freelist;
80102c5d:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c69:	74 0a                	je     80102c75 <kalloc+0x33>
    kmem.freelist = r->next;
80102c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c6e:	8b 00                	mov    (%eax),%eax
80102c70:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102c75:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102c7a:	85 c0                	test   %eax,%eax
80102c7c:	74 0c                	je     80102c8a <kalloc+0x48>
    release(&kmem.lock);
80102c7e:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102c85:	e8 f5 23 00 00       	call   8010507f <release>
  return (char*)r;
80102c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c8d:	c9                   	leave  
80102c8e:	c3                   	ret    

80102c8f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c8f:	55                   	push   %ebp
80102c90:	89 e5                	mov    %esp,%ebp
80102c92:	83 ec 14             	sub    $0x14,%esp
80102c95:	8b 45 08             	mov    0x8(%ebp),%eax
80102c98:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c9c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ca0:	89 c2                	mov    %eax,%edx
80102ca2:	ec                   	in     (%dx),%al
80102ca3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ca6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102caa:	c9                   	leave  
80102cab:	c3                   	ret    

80102cac <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cac:	55                   	push   %ebp
80102cad:	89 e5                	mov    %esp,%ebp
80102caf:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cb2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102cb9:	e8 d1 ff ff ff       	call   80102c8f <inb>
80102cbe:	0f b6 c0             	movzbl %al,%eax
80102cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc7:	83 e0 01             	and    $0x1,%eax
80102cca:	85 c0                	test   %eax,%eax
80102ccc:	75 0a                	jne    80102cd8 <kbdgetc+0x2c>
    return -1;
80102cce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cd3:	e9 25 01 00 00       	jmp    80102dfd <kbdgetc+0x151>
  data = inb(KBDATAP);
80102cd8:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102cdf:	e8 ab ff ff ff       	call   80102c8f <inb>
80102ce4:	0f b6 c0             	movzbl %al,%eax
80102ce7:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cea:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102cf1:	75 17                	jne    80102d0a <kbdgetc+0x5e>
    shift |= E0ESC;
80102cf3:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102cf8:	83 c8 40             	or     $0x40,%eax
80102cfb:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102d00:	b8 00 00 00 00       	mov    $0x0,%eax
80102d05:	e9 f3 00 00 00       	jmp    80102dfd <kbdgetc+0x151>
  } else if(data & 0x80){
80102d0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d0d:	25 80 00 00 00       	and    $0x80,%eax
80102d12:	85 c0                	test   %eax,%eax
80102d14:	74 45                	je     80102d5b <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d16:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d1b:	83 e0 40             	and    $0x40,%eax
80102d1e:	85 c0                	test   %eax,%eax
80102d20:	75 08                	jne    80102d2a <kbdgetc+0x7e>
80102d22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d25:	83 e0 7f             	and    $0x7f,%eax
80102d28:	eb 03                	jmp    80102d2d <kbdgetc+0x81>
80102d2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d33:	05 20 90 10 80       	add    $0x80109020,%eax
80102d38:	0f b6 00             	movzbl (%eax),%eax
80102d3b:	83 c8 40             	or     $0x40,%eax
80102d3e:	0f b6 c0             	movzbl %al,%eax
80102d41:	f7 d0                	not    %eax
80102d43:	89 c2                	mov    %eax,%edx
80102d45:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d4a:	21 d0                	and    %edx,%eax
80102d4c:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102d51:	b8 00 00 00 00       	mov    $0x0,%eax
80102d56:	e9 a2 00 00 00       	jmp    80102dfd <kbdgetc+0x151>
  } else if(shift & E0ESC){
80102d5b:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d60:	83 e0 40             	and    $0x40,%eax
80102d63:	85 c0                	test   %eax,%eax
80102d65:	74 14                	je     80102d7b <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d67:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d6e:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d73:	83 e0 bf             	and    $0xffffffbf,%eax
80102d76:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102d7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7e:	05 20 90 10 80       	add    $0x80109020,%eax
80102d83:	0f b6 00             	movzbl (%eax),%eax
80102d86:	0f b6 d0             	movzbl %al,%edx
80102d89:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102d8e:	09 d0                	or     %edx,%eax
80102d90:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102d95:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d98:	05 20 91 10 80       	add    $0x80109120,%eax
80102d9d:	0f b6 00             	movzbl (%eax),%eax
80102da0:	0f b6 d0             	movzbl %al,%edx
80102da3:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102da8:	31 d0                	xor    %edx,%eax
80102daa:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102daf:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102db4:	83 e0 03             	and    $0x3,%eax
80102db7:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102dbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc1:	01 d0                	add    %edx,%eax
80102dc3:	0f b6 00             	movzbl (%eax),%eax
80102dc6:	0f b6 c0             	movzbl %al,%eax
80102dc9:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102dcc:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102dd1:	83 e0 08             	and    $0x8,%eax
80102dd4:	85 c0                	test   %eax,%eax
80102dd6:	74 22                	je     80102dfa <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
80102dd8:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102ddc:	76 0c                	jbe    80102dea <kbdgetc+0x13e>
80102dde:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102de2:	77 06                	ja     80102dea <kbdgetc+0x13e>
      c += 'A' - 'a';
80102de4:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102de8:	eb 10                	jmp    80102dfa <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
80102dea:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102dee:	76 0a                	jbe    80102dfa <kbdgetc+0x14e>
80102df0:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102df4:	77 04                	ja     80102dfa <kbdgetc+0x14e>
      c += 'a' - 'A';
80102df6:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102dfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102dfd:	c9                   	leave  
80102dfe:	c3                   	ret    

80102dff <kbdintr>:

void
kbdintr(void)
{
80102dff:	55                   	push   %ebp
80102e00:	89 e5                	mov    %esp,%ebp
80102e02:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102e05:	c7 04 24 ac 2c 10 80 	movl   $0x80102cac,(%esp)
80102e0c:	e8 9c d9 ff ff       	call   801007ad <consoleintr>
}
80102e11:	c9                   	leave  
80102e12:	c3                   	ret    

80102e13 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e13:	55                   	push   %ebp
80102e14:	89 e5                	mov    %esp,%ebp
80102e16:	83 ec 08             	sub    $0x8,%esp
80102e19:	8b 55 08             	mov    0x8(%ebp),%edx
80102e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e1f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e23:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e26:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e2a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e2e:	ee                   	out    %al,(%dx)
}
80102e2f:	c9                   	leave  
80102e30:	c3                   	ret    

80102e31 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e31:	55                   	push   %ebp
80102e32:	89 e5                	mov    %esp,%ebp
80102e34:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e37:	9c                   	pushf  
80102e38:	58                   	pop    %eax
80102e39:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e3f:	c9                   	leave  
80102e40:	c3                   	ret    

80102e41 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e41:	55                   	push   %ebp
80102e42:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e44:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e49:	8b 55 08             	mov    0x8(%ebp),%edx
80102e4c:	c1 e2 02             	shl    $0x2,%edx
80102e4f:	01 c2                	add    %eax,%edx
80102e51:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e54:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e56:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e5b:	83 c0 20             	add    $0x20,%eax
80102e5e:	8b 00                	mov    (%eax),%eax
}
80102e60:	5d                   	pop    %ebp
80102e61:	c3                   	ret    

80102e62 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e62:	55                   	push   %ebp
80102e63:	89 e5                	mov    %esp,%ebp
80102e65:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102e68:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e6d:	85 c0                	test   %eax,%eax
80102e6f:	75 05                	jne    80102e76 <lapicinit+0x14>
    return;
80102e71:	e9 43 01 00 00       	jmp    80102fb9 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e76:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102e7d:	00 
80102e7e:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102e85:	e8 b7 ff ff ff       	call   80102e41 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e8a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102e91:	00 
80102e92:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102e99:	e8 a3 ff ff ff       	call   80102e41 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e9e:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102ea5:	00 
80102ea6:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ead:	e8 8f ff ff ff       	call   80102e41 <lapicw>
  lapicw(TICR, 10000000); 
80102eb2:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102eb9:	00 
80102eba:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102ec1:	e8 7b ff ff ff       	call   80102e41 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ec6:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102ecd:	00 
80102ece:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102ed5:	e8 67 ff ff ff       	call   80102e41 <lapicw>
  lapicw(LINT1, MASKED);
80102eda:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102ee1:	00 
80102ee2:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102ee9:	e8 53 ff ff ff       	call   80102e41 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102eee:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ef3:	83 c0 30             	add    $0x30,%eax
80102ef6:	8b 00                	mov    (%eax),%eax
80102ef8:	c1 e8 10             	shr    $0x10,%eax
80102efb:	0f b6 c0             	movzbl %al,%eax
80102efe:	83 f8 03             	cmp    $0x3,%eax
80102f01:	76 14                	jbe    80102f17 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102f03:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f0a:	00 
80102f0b:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102f12:	e8 2a ff ff ff       	call   80102e41 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f17:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102f1e:	00 
80102f1f:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102f26:	e8 16 ff ff ff       	call   80102e41 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f32:	00 
80102f33:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f3a:	e8 02 ff ff ff       	call   80102e41 <lapicw>
  lapicw(ESR, 0);
80102f3f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f46:	00 
80102f47:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f4e:	e8 ee fe ff ff       	call   80102e41 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f5a:	00 
80102f5b:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f62:	e8 da fe ff ff       	call   80102e41 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f6e:	00 
80102f6f:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f76:	e8 c6 fe ff ff       	call   80102e41 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f7b:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102f82:	00 
80102f83:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f8a:	e8 b2 fe ff ff       	call   80102e41 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102f8f:	90                   	nop
80102f90:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102f95:	05 00 03 00 00       	add    $0x300,%eax
80102f9a:	8b 00                	mov    (%eax),%eax
80102f9c:	25 00 10 00 00       	and    $0x1000,%eax
80102fa1:	85 c0                	test   %eax,%eax
80102fa3:	75 eb                	jne    80102f90 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fa5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fac:	00 
80102fad:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102fb4:	e8 88 fe ff ff       	call   80102e41 <lapicw>
}
80102fb9:	c9                   	leave  
80102fba:	c3                   	ret    

80102fbb <cpunum>:

int
cpunum(void)
{
80102fbb:	55                   	push   %ebp
80102fbc:	89 e5                	mov    %esp,%ebp
80102fbe:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fc1:	e8 6b fe ff ff       	call   80102e31 <readeflags>
80102fc6:	25 00 02 00 00       	and    $0x200,%eax
80102fcb:	85 c0                	test   %eax,%eax
80102fcd:	74 25                	je     80102ff4 <cpunum+0x39>
    static int n;
    if(n++ == 0)
80102fcf:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102fd4:	8d 50 01             	lea    0x1(%eax),%edx
80102fd7:	89 15 60 b6 10 80    	mov    %edx,0x8010b660
80102fdd:	85 c0                	test   %eax,%eax
80102fdf:	75 13                	jne    80102ff4 <cpunum+0x39>
      cprintf("cpu called from %x with interrupts enabled\n",
80102fe1:	8b 45 04             	mov    0x4(%ebp),%eax
80102fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fe8:	c7 04 24 24 8a 10 80 	movl   $0x80108a24,(%esp)
80102fef:	e8 ac d3 ff ff       	call   801003a0 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102ff4:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102ff9:	85 c0                	test   %eax,%eax
80102ffb:	74 0f                	je     8010300c <cpunum+0x51>
    return lapic[ID]>>24;
80102ffd:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80103002:	83 c0 20             	add    $0x20,%eax
80103005:	8b 00                	mov    (%eax),%eax
80103007:	c1 e8 18             	shr    $0x18,%eax
8010300a:	eb 05                	jmp    80103011 <cpunum+0x56>
  return 0;
8010300c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103011:	c9                   	leave  
80103012:	c3                   	ret    

80103013 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103013:	55                   	push   %ebp
80103014:	89 e5                	mov    %esp,%ebp
80103016:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103019:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
8010301e:	85 c0                	test   %eax,%eax
80103020:	74 14                	je     80103036 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103022:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103029:	00 
8010302a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103031:	e8 0b fe ff ff       	call   80102e41 <lapicw>
}
80103036:	c9                   	leave  
80103037:	c3                   	ret    

80103038 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103038:	55                   	push   %ebp
80103039:	89 e5                	mov    %esp,%ebp
}
8010303b:	5d                   	pop    %ebp
8010303c:	c3                   	ret    

8010303d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010303d:	55                   	push   %ebp
8010303e:	89 e5                	mov    %esp,%ebp
80103040:	83 ec 1c             	sub    $0x1c,%esp
80103043:	8b 45 08             	mov    0x8(%ebp),%eax
80103046:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80103049:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103050:	00 
80103051:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103058:	e8 b6 fd ff ff       	call   80102e13 <outb>
  outb(IO_RTC+1, 0x0A);
8010305d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103064:	00 
80103065:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010306c:	e8 a2 fd ff ff       	call   80102e13 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103071:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103078:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010307b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103080:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103083:	8d 50 02             	lea    0x2(%eax),%edx
80103086:	8b 45 0c             	mov    0xc(%ebp),%eax
80103089:	c1 e8 04             	shr    $0x4,%eax
8010308c:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010308f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103093:	c1 e0 18             	shl    $0x18,%eax
80103096:	89 44 24 04          	mov    %eax,0x4(%esp)
8010309a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030a1:	e8 9b fd ff ff       	call   80102e41 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030a6:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801030ad:	00 
801030ae:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030b5:	e8 87 fd ff ff       	call   80102e41 <lapicw>
  microdelay(200);
801030ba:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030c1:	e8 72 ff ff ff       	call   80103038 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801030c6:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801030cd:	00 
801030ce:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030d5:	e8 67 fd ff ff       	call   80102e41 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030da:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801030e1:	e8 52 ff ff ff       	call   80103038 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030ed:	eb 40                	jmp    8010312f <lapicstartap+0xf2>
    lapicw(ICRHI, apicid<<24);
801030ef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030f3:	c1 e0 18             	shl    $0x18,%eax
801030f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801030fa:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103101:	e8 3b fd ff ff       	call   80102e41 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103106:	8b 45 0c             	mov    0xc(%ebp),%eax
80103109:	c1 e8 0c             	shr    $0xc,%eax
8010310c:	80 cc 06             	or     $0x6,%ah
8010310f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103113:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010311a:	e8 22 fd ff ff       	call   80102e41 <lapicw>
    microdelay(200);
8010311f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103126:	e8 0d ff ff ff       	call   80103038 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010312b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010312f:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103133:	7e ba                	jle    801030ef <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103135:	c9                   	leave  
80103136:	c3                   	ret    

80103137 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80103137:	55                   	push   %ebp
80103138:	89 e5                	mov    %esp,%ebp
8010313a:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010313d:	c7 44 24 04 50 8a 10 	movl   $0x80108a50,0x4(%esp)
80103144:	80 
80103145:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010314c:	e8 ab 1e 00 00       	call   80104ffc <initlock>
  readsb(ROOTDEV, &sb);
80103151:	8d 45 e8             	lea    -0x18(%ebp),%eax
80103154:	89 44 24 04          	mov    %eax,0x4(%esp)
80103158:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010315f:	e8 79 e1 ff ff       	call   801012dd <readsb>
  log.start = sb.size - sb.nlog;
80103164:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103167:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010316a:	29 c2                	sub    %eax,%edx
8010316c:	89 d0                	mov    %edx,%eax
8010316e:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
80103173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103176:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
8010317b:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
80103182:	00 00 00 
  recover_from_log();
80103185:	e8 9a 01 00 00       	call   80103324 <recover_from_log>
}
8010318a:	c9                   	leave  
8010318b:	c3                   	ret    

8010318c <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010318c:	55                   	push   %ebp
8010318d:	89 e5                	mov    %esp,%ebp
8010318f:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103192:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103199:	e9 8c 00 00 00       	jmp    8010322a <install_trans+0x9e>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010319e:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
801031a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a7:	01 d0                	add    %edx,%eax
801031a9:	83 c0 01             	add    $0x1,%eax
801031ac:	89 c2                	mov    %eax,%edx
801031ae:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801031b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801031b7:	89 04 24             	mov    %eax,(%esp)
801031ba:	e8 e7 cf ff ff       	call   801001a6 <bread>
801031bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
801031c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c5:	83 c0 10             	add    $0x10,%eax
801031c8:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801031cf:	89 c2                	mov    %eax,%edx
801031d1:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801031d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801031da:	89 04 24             	mov    %eax,(%esp)
801031dd:	e8 c4 cf ff ff       	call   801001a6 <bread>
801031e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801031e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031e8:	8d 50 18             	lea    0x18(%eax),%edx
801031eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ee:	83 c0 18             	add    $0x18,%eax
801031f1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801031f8:	00 
801031f9:	89 54 24 04          	mov    %edx,0x4(%esp)
801031fd:	89 04 24             	mov    %eax,(%esp)
80103200:	e8 3b 21 00 00       	call   80105340 <memmove>
    bwrite(dbuf);  // write dst to disk
80103205:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103208:	89 04 24             	mov    %eax,(%esp)
8010320b:	e8 cd cf ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
80103210:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103213:	89 04 24             	mov    %eax,(%esp)
80103216:	e8 fc cf ff ff       	call   80100217 <brelse>
    brelse(dbuf);
8010321b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010321e:	89 04 24             	mov    %eax,(%esp)
80103221:	e8 f1 cf ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103226:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010322a:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010322f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103232:	0f 8f 66 ff ff ff    	jg     8010319e <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103238:	c9                   	leave  
80103239:	c3                   	ret    

8010323a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010323a:	55                   	push   %ebp
8010323b:	89 e5                	mov    %esp,%ebp
8010323d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103240:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
80103245:	89 c2                	mov    %eax,%edx
80103247:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
8010324c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103250:	89 04 24             	mov    %eax,(%esp)
80103253:	e8 4e cf ff ff       	call   801001a6 <bread>
80103258:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010325b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010325e:	83 c0 18             	add    $0x18,%eax
80103261:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103264:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103267:	8b 00                	mov    (%eax),%eax
80103269:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
8010326e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103275:	eb 1b                	jmp    80103292 <read_head+0x58>
    log.lh.sector[i] = lh->sector[i];
80103277:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010327a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010327d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103281:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103284:	83 c2 10             	add    $0x10,%edx
80103287:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010328e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103292:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103297:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010329a:	7f db                	jg     80103277 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
8010329c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010329f:	89 04 24             	mov    %eax,(%esp)
801032a2:	e8 70 cf ff ff       	call   80100217 <brelse>
}
801032a7:	c9                   	leave  
801032a8:	c3                   	ret    

801032a9 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801032a9:	55                   	push   %ebp
801032aa:	89 e5                	mov    %esp,%ebp
801032ac:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801032af:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801032b4:	89 c2                	mov    %eax,%edx
801032b6:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801032bb:	89 54 24 04          	mov    %edx,0x4(%esp)
801032bf:	89 04 24             	mov    %eax,(%esp)
801032c2:	e8 df ce ff ff       	call   801001a6 <bread>
801032c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801032ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801032cd:	83 c0 18             	add    $0x18,%eax
801032d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801032d3:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
801032d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032dc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801032de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032e5:	eb 1b                	jmp    80103302 <write_head+0x59>
    hb->sector[i] = log.lh.sector[i];
801032e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032ea:	83 c0 10             	add    $0x10,%eax
801032ed:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
801032f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801032fa:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801032fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103302:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103307:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010330a:	7f db                	jg     801032e7 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
8010330c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010330f:	89 04 24             	mov    %eax,(%esp)
80103312:	e8 c6 ce ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103317:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010331a:	89 04 24             	mov    %eax,(%esp)
8010331d:	e8 f5 ce ff ff       	call   80100217 <brelse>
}
80103322:	c9                   	leave  
80103323:	c3                   	ret    

80103324 <recover_from_log>:

static void
recover_from_log(void)
{
80103324:	55                   	push   %ebp
80103325:	89 e5                	mov    %esp,%ebp
80103327:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010332a:	e8 0b ff ff ff       	call   8010323a <read_head>
  install_trans(); // if committed, copy from log to disk
8010332f:	e8 58 fe ff ff       	call   8010318c <install_trans>
  log.lh.n = 0;
80103334:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
8010333b:	00 00 00 
  write_head(); // clear the log
8010333e:	e8 66 ff ff ff       	call   801032a9 <write_head>
}
80103343:	c9                   	leave  
80103344:	c3                   	ret    

80103345 <begin_trans>:

void
begin_trans(void)
{
80103345:	55                   	push   %ebp
80103346:	89 e5                	mov    %esp,%ebp
80103348:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
8010334b:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103352:	e8 c6 1c 00 00       	call   8010501d <acquire>
  while (log.busy) {
80103357:	eb 14                	jmp    8010336d <begin_trans+0x28>
    sleep(&log, &log.lock);
80103359:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
80103360:	80 
80103361:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103368:	e8 2e 16 00 00       	call   8010499b <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
8010336d:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103372:	85 c0                	test   %eax,%eax
80103374:	75 e3                	jne    80103359 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
80103376:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
8010337d:	00 00 00 
  release(&log.lock);
80103380:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103387:	e8 f3 1c 00 00       	call   8010507f <release>
}
8010338c:	c9                   	leave  
8010338d:	c3                   	ret    

8010338e <commit_trans>:

void
commit_trans(void)
{
8010338e:	55                   	push   %ebp
8010338f:	89 e5                	mov    %esp,%ebp
80103391:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
80103394:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103399:	85 c0                	test   %eax,%eax
8010339b:	7e 19                	jle    801033b6 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
8010339d:	e8 07 ff ff ff       	call   801032a9 <write_head>
    install_trans(); // Now install writes to home locations
801033a2:	e8 e5 fd ff ff       	call   8010318c <install_trans>
    log.lh.n = 0; 
801033a7:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801033ae:	00 00 00 
    write_head();    // Erase the transaction from the log
801033b1:	e8 f3 fe ff ff       	call   801032a9 <write_head>
  }
  
  acquire(&log.lock);
801033b6:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801033bd:	e8 5b 1c 00 00       	call   8010501d <acquire>
  log.busy = 0;
801033c2:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
801033c9:	00 00 00 
  wakeup(&log);
801033cc:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801033d3:	e8 9f 16 00 00       	call   80104a77 <wakeup>
  release(&log.lock);
801033d8:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801033df:	e8 9b 1c 00 00       	call   8010507f <release>
}
801033e4:	c9                   	leave  
801033e5:	c3                   	ret    

801033e6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801033e6:	55                   	push   %ebp
801033e7:	89 e5                	mov    %esp,%ebp
801033e9:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801033ec:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801033f1:	83 f8 09             	cmp    $0x9,%eax
801033f4:	7f 12                	jg     80103408 <log_write+0x22>
801033f6:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801033fb:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
80103401:	83 ea 01             	sub    $0x1,%edx
80103404:	39 d0                	cmp    %edx,%eax
80103406:	7c 0c                	jl     80103414 <log_write+0x2e>
    panic("too big a transaction");
80103408:	c7 04 24 54 8a 10 80 	movl   $0x80108a54,(%esp)
8010340f:	e8 26 d1 ff ff       	call   8010053a <panic>
  if (!log.busy)
80103414:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103419:	85 c0                	test   %eax,%eax
8010341b:	75 0c                	jne    80103429 <log_write+0x43>
    panic("write outside of trans");
8010341d:	c7 04 24 6a 8a 10 80 	movl   $0x80108a6a,(%esp)
80103424:	e8 11 d1 ff ff       	call   8010053a <panic>

  for (i = 0; i < log.lh.n; i++) {
80103429:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103430:	eb 1f                	jmp    80103451 <log_write+0x6b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
80103432:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103435:	83 c0 10             	add    $0x10,%eax
80103438:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	8b 45 08             	mov    0x8(%ebp),%eax
80103444:	8b 40 08             	mov    0x8(%eax),%eax
80103447:	39 c2                	cmp    %eax,%edx
80103449:	75 02                	jne    8010344d <log_write+0x67>
      break;
8010344b:	eb 0e                	jmp    8010345b <log_write+0x75>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
8010344d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103451:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103456:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103459:	7f d7                	jg     80103432 <log_write+0x4c>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
  }
  log.lh.sector[i] = b->sector;
8010345b:	8b 45 08             	mov    0x8(%ebp),%eax
8010345e:	8b 40 08             	mov    0x8(%eax),%eax
80103461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103464:	83 c2 10             	add    $0x10,%edx
80103467:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
8010346e:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
80103474:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103477:	01 d0                	add    %edx,%eax
80103479:	83 c0 01             	add    $0x1,%eax
8010347c:	89 c2                	mov    %eax,%edx
8010347e:	8b 45 08             	mov    0x8(%ebp),%eax
80103481:	8b 40 04             	mov    0x4(%eax),%eax
80103484:	89 54 24 04          	mov    %edx,0x4(%esp)
80103488:	89 04 24             	mov    %eax,(%esp)
8010348b:	e8 16 cd ff ff       	call   801001a6 <bread>
80103490:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
80103493:	8b 45 08             	mov    0x8(%ebp),%eax
80103496:	8d 50 18             	lea    0x18(%eax),%edx
80103499:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010349c:	83 c0 18             	add    $0x18,%eax
8010349f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801034a6:	00 
801034a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801034ab:	89 04 24             	mov    %eax,(%esp)
801034ae:	e8 8d 1e 00 00       	call   80105340 <memmove>
  bwrite(lbuf);
801034b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b6:	89 04 24             	mov    %eax,(%esp)
801034b9:	e8 1f cd ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
801034be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034c1:	89 04 24             	mov    %eax,(%esp)
801034c4:	e8 4e cd ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
801034c9:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034ce:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034d1:	75 0d                	jne    801034e0 <log_write+0xfa>
    log.lh.n++;
801034d3:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801034d8:	83 c0 01             	add    $0x1,%eax
801034db:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
801034e0:	8b 45 08             	mov    0x8(%ebp),%eax
801034e3:	8b 00                	mov    (%eax),%eax
801034e5:	83 c8 04             	or     $0x4,%eax
801034e8:	89 c2                	mov    %eax,%edx
801034ea:	8b 45 08             	mov    0x8(%ebp),%eax
801034ed:	89 10                	mov    %edx,(%eax)
}
801034ef:	c9                   	leave  
801034f0:	c3                   	ret    

801034f1 <v2p>:
801034f1:	55                   	push   %ebp
801034f2:	89 e5                	mov    %esp,%ebp
801034f4:	8b 45 08             	mov    0x8(%ebp),%eax
801034f7:	05 00 00 00 80       	add    $0x80000000,%eax
801034fc:	5d                   	pop    %ebp
801034fd:	c3                   	ret    

801034fe <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	8b 45 08             	mov    0x8(%ebp),%eax
80103504:	05 00 00 00 80       	add    $0x80000000,%eax
80103509:	5d                   	pop    %ebp
8010350a:	c3                   	ret    

8010350b <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010350b:	55                   	push   %ebp
8010350c:	89 e5                	mov    %esp,%ebp
8010350e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103511:	8b 55 08             	mov    0x8(%ebp),%edx
80103514:	8b 45 0c             	mov    0xc(%ebp),%eax
80103517:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010351a:	f0 87 02             	lock xchg %eax,(%edx)
8010351d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103520:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103523:	c9                   	leave  
80103524:	c3                   	ret    

80103525 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103525:	55                   	push   %ebp
80103526:	89 e5                	mov    %esp,%ebp
80103528:	83 e4 f0             	and    $0xfffffff0,%esp
8010352b:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010352e:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103535:	80 
80103536:	c7 04 24 3c 94 11 80 	movl   $0x8011943c,(%esp)
8010353d:	e8 d2 f5 ff ff       	call   80102b14 <kinit1>
  kvmalloc();      // kernel page table
80103542:	e8 4f 4b 00 00       	call   80108096 <kvmalloc>
  mpinit();        // collect info about this machine
80103547:	e8 46 04 00 00       	call   80103992 <mpinit>
  lapicinit();
8010354c:	e8 11 f9 ff ff       	call   80102e62 <lapicinit>
  seginit();       // set up segments
80103551:	e8 d3 44 00 00       	call   80107a29 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103556:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010355c:	0f b6 00             	movzbl (%eax),%eax
8010355f:	0f b6 c0             	movzbl %al,%eax
80103562:	89 44 24 04          	mov    %eax,0x4(%esp)
80103566:	c7 04 24 81 8a 10 80 	movl   $0x80108a81,(%esp)
8010356d:	e8 2e ce ff ff       	call   801003a0 <cprintf>
  picinit();       // interrupt controller
80103572:	e8 79 06 00 00       	call   80103bf0 <picinit>
  ioapicinit();    // another interrupt controller
80103577:	e8 8e f4 ff ff       	call   80102a0a <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010357c:	e8 00 d5 ff ff       	call   80100a81 <consoleinit>
  uartinit();      // serial port
80103581:	e8 f2 37 00 00       	call   80106d78 <uartinit>
  pinit();         // process table
80103586:	e8 89 0b 00 00       	call   80104114 <pinit>
  tvinit();        // trap vectors
8010358b:	e8 9a 33 00 00       	call   8010692a <tvinit>
  binit();         // buffer cache
80103590:	e8 9f ca ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103595:	e8 5c d9 ff ff       	call   80100ef6 <fileinit>
  iinit();         // inode cache
8010359a:	e8 f1 df ff ff       	call   80101590 <iinit>
  ideinit();       // disk
8010359f:	e8 cf f0 ff ff       	call   80102673 <ideinit>
  if(!ismp)
801035a4:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801035a9:	85 c0                	test   %eax,%eax
801035ab:	75 05                	jne    801035b2 <main+0x8d>
    timerinit();   // uniprocessor timer
801035ad:	e8 c3 32 00 00       	call   80106875 <timerinit>
  startothers();   // start other processors
801035b2:	e8 7f 00 00 00       	call   80103636 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801035b7:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801035be:	8e 
801035bf:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801035c6:	e8 81 f5 ff ff       	call   80102b4c <kinit2>
  userinit();      // first user process
801035cb:	e8 80 0c 00 00       	call   80104250 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801035d0:	e8 1a 00 00 00       	call   801035ef <mpmain>

801035d5 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801035d5:	55                   	push   %ebp
801035d6:	89 e5                	mov    %esp,%ebp
801035d8:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801035db:	e8 cd 4a 00 00       	call   801080ad <switchkvm>
  seginit();
801035e0:	e8 44 44 00 00       	call   80107a29 <seginit>
  lapicinit();
801035e5:	e8 78 f8 ff ff       	call   80102e62 <lapicinit>
  mpmain();
801035ea:	e8 00 00 00 00       	call   801035ef <mpmain>

801035ef <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801035ef:	55                   	push   %ebp
801035f0:	89 e5                	mov    %esp,%ebp
801035f2:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801035f5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801035fb:	0f b6 00             	movzbl (%eax),%eax
801035fe:	0f b6 c0             	movzbl %al,%eax
80103601:	89 44 24 04          	mov    %eax,0x4(%esp)
80103605:	c7 04 24 98 8a 10 80 	movl   $0x80108a98,(%esp)
8010360c:	e8 8f cd ff ff       	call   801003a0 <cprintf>
  idtinit();       // load idt register
80103611:	e8 88 34 00 00       	call   80106a9e <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103616:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010361c:	05 a8 00 00 00       	add    $0xa8,%eax
80103621:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103628:	00 
80103629:	89 04 24             	mov    %eax,(%esp)
8010362c:	e8 da fe ff ff       	call   8010350b <xchg>
  scheduler();     // start running processes
80103631:	e8 ba 11 00 00       	call   801047f0 <scheduler>

80103636 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103636:	55                   	push   %ebp
80103637:	89 e5                	mov    %esp,%ebp
80103639:	53                   	push   %ebx
8010363a:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010363d:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
80103644:	e8 b5 fe ff ff       	call   801034fe <p2v>
80103649:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010364c:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103651:	89 44 24 08          	mov    %eax,0x8(%esp)
80103655:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
8010365c:	80 
8010365d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103660:	89 04 24             	mov    %eax,(%esp)
80103663:	e8 d8 1c 00 00       	call   80105340 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103668:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
8010366f:	e9 85 00 00 00       	jmp    801036f9 <startothers+0xc3>
    if(c == cpus+cpunum())  // We've started already.
80103674:	e8 42 f9 ff ff       	call   80102fbb <cpunum>
80103679:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010367f:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103684:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103687:	75 02                	jne    8010368b <startothers+0x55>
      continue;
80103689:	eb 67                	jmp    801036f2 <startothers+0xbc>

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010368b:	e8 b2 f5 ff ff       	call   80102c42 <kalloc>
80103690:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103693:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103696:	83 e8 04             	sub    $0x4,%eax
80103699:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010369c:	81 c2 00 10 00 00    	add    $0x1000,%edx
801036a2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801036a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036a7:	83 e8 08             	sub    $0x8,%eax
801036aa:	c7 00 d5 35 10 80    	movl   $0x801035d5,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
801036b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036b3:	8d 58 f4             	lea    -0xc(%eax),%ebx
801036b6:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
801036bd:	e8 2f fe ff ff       	call   801034f1 <v2p>
801036c2:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801036c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036c7:	89 04 24             	mov    %eax,(%esp)
801036ca:	e8 22 fe ff ff       	call   801034f1 <v2p>
801036cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036d2:	0f b6 12             	movzbl (%edx),%edx
801036d5:	0f b6 d2             	movzbl %dl,%edx
801036d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801036dc:	89 14 24             	mov    %edx,(%esp)
801036df:	e8 59 f9 ff ff       	call   8010303d <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801036e4:	90                   	nop
801036e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e8:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801036ee:	85 c0                	test   %eax,%eax
801036f0:	74 f3                	je     801036e5 <startothers+0xaf>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801036f2:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801036f9:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801036fe:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103704:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103709:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010370c:	0f 87 62 ff ff ff    	ja     80103674 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103712:	83 c4 24             	add    $0x24,%esp
80103715:	5b                   	pop    %ebx
80103716:	5d                   	pop    %ebp
80103717:	c3                   	ret    

80103718 <p2v>:
80103718:	55                   	push   %ebp
80103719:	89 e5                	mov    %esp,%ebp
8010371b:	8b 45 08             	mov    0x8(%ebp),%eax
8010371e:	05 00 00 00 80       	add    $0x80000000,%eax
80103723:	5d                   	pop    %ebp
80103724:	c3                   	ret    

80103725 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103725:	55                   	push   %ebp
80103726:	89 e5                	mov    %esp,%ebp
80103728:	83 ec 14             	sub    $0x14,%esp
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103732:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103736:	89 c2                	mov    %eax,%edx
80103738:	ec                   	in     (%dx),%al
80103739:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010373c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103740:	c9                   	leave  
80103741:	c3                   	ret    

80103742 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103742:	55                   	push   %ebp
80103743:	89 e5                	mov    %esp,%ebp
80103745:	83 ec 08             	sub    $0x8,%esp
80103748:	8b 55 08             	mov    0x8(%ebp),%edx
8010374b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010374e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103752:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103755:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103759:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010375d:	ee                   	out    %al,(%dx)
}
8010375e:	c9                   	leave  
8010375f:	c3                   	ret    

80103760 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103760:	55                   	push   %ebp
80103761:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103763:	a1 64 b6 10 80       	mov    0x8010b664,%eax
80103768:	89 c2                	mov    %eax,%edx
8010376a:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
8010376f:	29 c2                	sub    %eax,%edx
80103771:	89 d0                	mov    %edx,%eax
80103773:	c1 f8 02             	sar    $0x2,%eax
80103776:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
8010377c:	5d                   	pop    %ebp
8010377d:	c3                   	ret    

8010377e <sum>:

static uchar
sum(uchar *addr, int len)
{
8010377e:	55                   	push   %ebp
8010377f:	89 e5                	mov    %esp,%ebp
80103781:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103784:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
8010378b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103792:	eb 15                	jmp    801037a9 <sum+0x2b>
    sum += addr[i];
80103794:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103797:	8b 45 08             	mov    0x8(%ebp),%eax
8010379a:	01 d0                	add    %edx,%eax
8010379c:	0f b6 00             	movzbl (%eax),%eax
8010379f:	0f b6 c0             	movzbl %al,%eax
801037a2:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
801037a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801037a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801037ac:	3b 45 0c             	cmp    0xc(%ebp),%eax
801037af:	7c e3                	jl     80103794 <sum+0x16>
    sum += addr[i];
  return sum;
801037b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801037b4:	c9                   	leave  
801037b5:	c3                   	ret    

801037b6 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801037b6:	55                   	push   %ebp
801037b7:	89 e5                	mov    %esp,%ebp
801037b9:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
801037bc:	8b 45 08             	mov    0x8(%ebp),%eax
801037bf:	89 04 24             	mov    %eax,(%esp)
801037c2:	e8 51 ff ff ff       	call   80103718 <p2v>
801037c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
801037ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801037cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d0:	01 d0                	add    %edx,%eax
801037d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
801037d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801037db:	eb 3f                	jmp    8010381c <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801037dd:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801037e4:	00 
801037e5:	c7 44 24 04 ac 8a 10 	movl   $0x80108aac,0x4(%esp)
801037ec:	80 
801037ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037f0:	89 04 24             	mov    %eax,(%esp)
801037f3:	e8 f0 1a 00 00       	call   801052e8 <memcmp>
801037f8:	85 c0                	test   %eax,%eax
801037fa:	75 1c                	jne    80103818 <mpsearch1+0x62>
801037fc:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103803:	00 
80103804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103807:	89 04 24             	mov    %eax,(%esp)
8010380a:	e8 6f ff ff ff       	call   8010377e <sum>
8010380f:	84 c0                	test   %al,%al
80103811:	75 05                	jne    80103818 <mpsearch1+0x62>
      return (struct mp*)p;
80103813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103816:	eb 11                	jmp    80103829 <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103818:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010381c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010381f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103822:	72 b9                	jb     801037dd <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103824:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103829:	c9                   	leave  
8010382a:	c3                   	ret    

8010382b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
8010382b:	55                   	push   %ebp
8010382c:	89 e5                	mov    %esp,%ebp
8010382e:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103831:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383b:	83 c0 0f             	add    $0xf,%eax
8010383e:	0f b6 00             	movzbl (%eax),%eax
80103841:	0f b6 c0             	movzbl %al,%eax
80103844:	c1 e0 08             	shl    $0x8,%eax
80103847:	89 c2                	mov    %eax,%edx
80103849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010384c:	83 c0 0e             	add    $0xe,%eax
8010384f:	0f b6 00             	movzbl (%eax),%eax
80103852:	0f b6 c0             	movzbl %al,%eax
80103855:	09 d0                	or     %edx,%eax
80103857:	c1 e0 04             	shl    $0x4,%eax
8010385a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010385d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103861:	74 21                	je     80103884 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103863:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010386a:	00 
8010386b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010386e:	89 04 24             	mov    %eax,(%esp)
80103871:	e8 40 ff ff ff       	call   801037b6 <mpsearch1>
80103876:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103879:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010387d:	74 50                	je     801038cf <mpsearch+0xa4>
      return mp;
8010387f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103882:	eb 5f                	jmp    801038e3 <mpsearch+0xb8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103887:	83 c0 14             	add    $0x14,%eax
8010388a:	0f b6 00             	movzbl (%eax),%eax
8010388d:	0f b6 c0             	movzbl %al,%eax
80103890:	c1 e0 08             	shl    $0x8,%eax
80103893:	89 c2                	mov    %eax,%edx
80103895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103898:	83 c0 13             	add    $0x13,%eax
8010389b:	0f b6 00             	movzbl (%eax),%eax
8010389e:	0f b6 c0             	movzbl %al,%eax
801038a1:	09 d0                	or     %edx,%eax
801038a3:	c1 e0 0a             	shl    $0xa,%eax
801038a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
801038a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038ac:	2d 00 04 00 00       	sub    $0x400,%eax
801038b1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
801038b8:	00 
801038b9:	89 04 24             	mov    %eax,(%esp)
801038bc:	e8 f5 fe ff ff       	call   801037b6 <mpsearch1>
801038c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801038c4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801038c8:	74 05                	je     801038cf <mpsearch+0xa4>
      return mp;
801038ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038cd:	eb 14                	jmp    801038e3 <mpsearch+0xb8>
  }
  return mpsearch1(0xF0000, 0x10000);
801038cf:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801038d6:	00 
801038d7:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801038de:	e8 d3 fe ff ff       	call   801037b6 <mpsearch1>
}
801038e3:	c9                   	leave  
801038e4:	c3                   	ret    

801038e5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801038e5:	55                   	push   %ebp
801038e6:	89 e5                	mov    %esp,%ebp
801038e8:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801038eb:	e8 3b ff ff ff       	call   8010382b <mpsearch>
801038f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801038f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801038f7:	74 0a                	je     80103903 <mpconfig+0x1e>
801038f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038fc:	8b 40 04             	mov    0x4(%eax),%eax
801038ff:	85 c0                	test   %eax,%eax
80103901:	75 0a                	jne    8010390d <mpconfig+0x28>
    return 0;
80103903:	b8 00 00 00 00       	mov    $0x0,%eax
80103908:	e9 83 00 00 00       	jmp    80103990 <mpconfig+0xab>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
8010390d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103910:	8b 40 04             	mov    0x4(%eax),%eax
80103913:	89 04 24             	mov    %eax,(%esp)
80103916:	e8 fd fd ff ff       	call   80103718 <p2v>
8010391b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010391e:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103925:	00 
80103926:	c7 44 24 04 b1 8a 10 	movl   $0x80108ab1,0x4(%esp)
8010392d:	80 
8010392e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103931:	89 04 24             	mov    %eax,(%esp)
80103934:	e8 af 19 00 00       	call   801052e8 <memcmp>
80103939:	85 c0                	test   %eax,%eax
8010393b:	74 07                	je     80103944 <mpconfig+0x5f>
    return 0;
8010393d:	b8 00 00 00 00       	mov    $0x0,%eax
80103942:	eb 4c                	jmp    80103990 <mpconfig+0xab>
  if(conf->version != 1 && conf->version != 4)
80103944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103947:	0f b6 40 06          	movzbl 0x6(%eax),%eax
8010394b:	3c 01                	cmp    $0x1,%al
8010394d:	74 12                	je     80103961 <mpconfig+0x7c>
8010394f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103952:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103956:	3c 04                	cmp    $0x4,%al
80103958:	74 07                	je     80103961 <mpconfig+0x7c>
    return 0;
8010395a:	b8 00 00 00 00       	mov    $0x0,%eax
8010395f:	eb 2f                	jmp    80103990 <mpconfig+0xab>
  if(sum((uchar*)conf, conf->length) != 0)
80103961:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103964:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103968:	0f b7 c0             	movzwl %ax,%eax
8010396b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010396f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103972:	89 04 24             	mov    %eax,(%esp)
80103975:	e8 04 fe ff ff       	call   8010377e <sum>
8010397a:	84 c0                	test   %al,%al
8010397c:	74 07                	je     80103985 <mpconfig+0xa0>
    return 0;
8010397e:	b8 00 00 00 00       	mov    $0x0,%eax
80103983:	eb 0b                	jmp    80103990 <mpconfig+0xab>
  *pmp = mp;
80103985:	8b 45 08             	mov    0x8(%ebp),%eax
80103988:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010398b:	89 10                	mov    %edx,(%eax)
  return conf;
8010398d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103990:	c9                   	leave  
80103991:	c3                   	ret    

80103992 <mpinit>:

void
mpinit(void)
{
80103992:	55                   	push   %ebp
80103993:	89 e5                	mov    %esp,%ebp
80103995:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103998:	c7 05 64 b6 10 80 40 	movl   $0x8010f940,0x8010b664
8010399f:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
801039a2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801039a5:	89 04 24             	mov    %eax,(%esp)
801039a8:	e8 38 ff ff ff       	call   801038e5 <mpconfig>
801039ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801039b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801039b4:	75 05                	jne    801039bb <mpinit+0x29>
    return;
801039b6:	e9 9c 01 00 00       	jmp    80103b57 <mpinit+0x1c5>
  ismp = 1;
801039bb:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
801039c2:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
801039c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c8:	8b 40 24             	mov    0x24(%eax),%eax
801039cb:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801039d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039d3:	83 c0 2c             	add    $0x2c,%eax
801039d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801039d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039dc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801039e0:	0f b7 d0             	movzwl %ax,%edx
801039e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e6:	01 d0                	add    %edx,%eax
801039e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801039eb:	e9 f4 00 00 00       	jmp    80103ae4 <mpinit+0x152>
    switch(*p){
801039f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039f3:	0f b6 00             	movzbl (%eax),%eax
801039f6:	0f b6 c0             	movzbl %al,%eax
801039f9:	83 f8 04             	cmp    $0x4,%eax
801039fc:	0f 87 bf 00 00 00    	ja     80103ac1 <mpinit+0x12f>
80103a02:	8b 04 85 f4 8a 10 80 	mov    -0x7fef750c(,%eax,4),%eax
80103a09:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a0e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103a11:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a14:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103a18:	0f b6 d0             	movzbl %al,%edx
80103a1b:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103a20:	39 c2                	cmp    %eax,%edx
80103a22:	74 2d                	je     80103a51 <mpinit+0xbf>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103a24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a27:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103a2b:	0f b6 d0             	movzbl %al,%edx
80103a2e:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103a33:	89 54 24 08          	mov    %edx,0x8(%esp)
80103a37:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a3b:	c7 04 24 b6 8a 10 80 	movl   $0x80108ab6,(%esp)
80103a42:	e8 59 c9 ff ff       	call   801003a0 <cprintf>
        ismp = 0;
80103a47:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103a4e:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103a51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103a54:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103a58:	0f b6 c0             	movzbl %al,%eax
80103a5b:	83 e0 02             	and    $0x2,%eax
80103a5e:	85 c0                	test   %eax,%eax
80103a60:	74 15                	je     80103a77 <mpinit+0xe5>
        bcpu = &cpus[ncpu];
80103a62:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103a67:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a6d:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103a72:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103a77:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103a7d:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103a82:	69 d2 bc 00 00 00    	imul   $0xbc,%edx,%edx
80103a88:	81 c2 40 f9 10 80    	add    $0x8010f940,%edx
80103a8e:	88 02                	mov    %al,(%edx)
      ncpu++;
80103a90:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103a95:	83 c0 01             	add    $0x1,%eax
80103a98:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103a9d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103aa1:	eb 41                	jmp    80103ae4 <mpinit+0x152>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103aa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103aac:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ab0:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
80103ab5:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ab9:	eb 29                	jmp    80103ae4 <mpinit+0x152>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103abb:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103abf:	eb 23                	jmp    80103ae4 <mpinit+0x152>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac4:	0f b6 00             	movzbl (%eax),%eax
80103ac7:	0f b6 c0             	movzbl %al,%eax
80103aca:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ace:	c7 04 24 d4 8a 10 80 	movl   $0x80108ad4,(%esp)
80103ad5:	e8 c6 c8 ff ff       	call   801003a0 <cprintf>
      ismp = 0;
80103ada:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103ae1:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103aea:	0f 82 00 ff ff ff    	jb     801039f0 <mpinit+0x5e>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103af0:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80103af5:	85 c0                	test   %eax,%eax
80103af7:	75 1d                	jne    80103b16 <mpinit+0x184>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103af9:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
80103b00:	00 00 00 
    lapic = 0;
80103b03:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
80103b0a:	00 00 00 
    ioapicid = 0;
80103b0d:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
    return;
80103b14:	eb 41                	jmp    80103b57 <mpinit+0x1c5>
  }

  if(mp->imcrp){
80103b16:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103b19:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103b1d:	84 c0                	test   %al,%al
80103b1f:	74 36                	je     80103b57 <mpinit+0x1c5>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103b21:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103b28:	00 
80103b29:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103b30:	e8 0d fc ff ff       	call   80103742 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103b35:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103b3c:	e8 e4 fb ff ff       	call   80103725 <inb>
80103b41:	83 c8 01             	or     $0x1,%eax
80103b44:	0f b6 c0             	movzbl %al,%eax
80103b47:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b4b:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103b52:	e8 eb fb ff ff       	call   80103742 <outb>
  }
}
80103b57:	c9                   	leave  
80103b58:	c3                   	ret    

80103b59 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b59:	55                   	push   %ebp
80103b5a:	89 e5                	mov    %esp,%ebp
80103b5c:	83 ec 08             	sub    $0x8,%esp
80103b5f:	8b 55 08             	mov    0x8(%ebp),%edx
80103b62:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b65:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b69:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b6c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b70:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b74:	ee                   	out    %al,(%dx)
}
80103b75:	c9                   	leave  
80103b76:	c3                   	ret    

80103b77 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103b77:	55                   	push   %ebp
80103b78:	89 e5                	mov    %esp,%ebp
80103b7a:	83 ec 0c             	sub    $0xc,%esp
80103b7d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b80:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103b84:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103b88:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103b8e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103b92:	0f b6 c0             	movzbl %al,%eax
80103b95:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b99:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ba0:	e8 b4 ff ff ff       	call   80103b59 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103ba5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ba9:	66 c1 e8 08          	shr    $0x8,%ax
80103bad:	0f b6 c0             	movzbl %al,%eax
80103bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bb4:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103bbb:	e8 99 ff ff ff       	call   80103b59 <outb>
}
80103bc0:	c9                   	leave  
80103bc1:	c3                   	ret    

80103bc2 <picenable>:

void
picenable(int irq)
{
80103bc2:	55                   	push   %ebp
80103bc3:	89 e5                	mov    %esp,%ebp
80103bc5:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcb:	ba 01 00 00 00       	mov    $0x1,%edx
80103bd0:	89 c1                	mov    %eax,%ecx
80103bd2:	d3 e2                	shl    %cl,%edx
80103bd4:	89 d0                	mov    %edx,%eax
80103bd6:	f7 d0                	not    %eax
80103bd8:	89 c2                	mov    %eax,%edx
80103bda:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103be1:	21 d0                	and    %edx,%eax
80103be3:	0f b7 c0             	movzwl %ax,%eax
80103be6:	89 04 24             	mov    %eax,(%esp)
80103be9:	e8 89 ff ff ff       	call   80103b77 <picsetmask>
}
80103bee:	c9                   	leave  
80103bef:	c3                   	ret    

80103bf0 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103bf0:	55                   	push   %ebp
80103bf1:	89 e5                	mov    %esp,%ebp
80103bf3:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103bf6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103bfd:	00 
80103bfe:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103c05:	e8 4f ff ff ff       	call   80103b59 <outb>
  outb(IO_PIC2+1, 0xFF);
80103c0a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103c11:	00 
80103c12:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103c19:	e8 3b ff ff ff       	call   80103b59 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103c1e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103c25:	00 
80103c26:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103c2d:	e8 27 ff ff ff       	call   80103b59 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103c32:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103c39:	00 
80103c3a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103c41:	e8 13 ff ff ff       	call   80103b59 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103c46:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103c4d:	00 
80103c4e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103c55:	e8 ff fe ff ff       	call   80103b59 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103c5a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103c61:	00 
80103c62:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103c69:	e8 eb fe ff ff       	call   80103b59 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103c6e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103c75:	00 
80103c76:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103c7d:	e8 d7 fe ff ff       	call   80103b59 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103c82:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103c89:	00 
80103c8a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103c91:	e8 c3 fe ff ff       	call   80103b59 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103c96:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103c9d:	00 
80103c9e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ca5:	e8 af fe ff ff       	call   80103b59 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103caa:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103cb1:	00 
80103cb2:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103cb9:	e8 9b fe ff ff       	call   80103b59 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103cbe:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103cc5:	00 
80103cc6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ccd:	e8 87 fe ff ff       	call   80103b59 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103cd2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103cd9:	00 
80103cda:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ce1:	e8 73 fe ff ff       	call   80103b59 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103ce6:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103ced:	00 
80103cee:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103cf5:	e8 5f fe ff ff       	call   80103b59 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103cfa:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103d01:	00 
80103d02:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103d09:	e8 4b fe ff ff       	call   80103b59 <outb>

  if(irqmask != 0xFFFF)
80103d0e:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103d15:	66 83 f8 ff          	cmp    $0xffff,%ax
80103d19:	74 12                	je     80103d2d <picinit+0x13d>
    picsetmask(irqmask);
80103d1b:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103d22:	0f b7 c0             	movzwl %ax,%eax
80103d25:	89 04 24             	mov    %eax,(%esp)
80103d28:	e8 4a fe ff ff       	call   80103b77 <picsetmask>
}
80103d2d:	c9                   	leave  
80103d2e:	c3                   	ret    

80103d2f <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103d2f:	55                   	push   %ebp
80103d30:	89 e5                	mov    %esp,%ebp
80103d32:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103d35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d3f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103d45:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d48:	8b 10                	mov    (%eax),%edx
80103d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d4d:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103d4f:	e8 be d1 ff ff       	call   80100f12 <filealloc>
80103d54:	8b 55 08             	mov    0x8(%ebp),%edx
80103d57:	89 02                	mov    %eax,(%edx)
80103d59:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5c:	8b 00                	mov    (%eax),%eax
80103d5e:	85 c0                	test   %eax,%eax
80103d60:	0f 84 c8 00 00 00    	je     80103e2e <pipealloc+0xff>
80103d66:	e8 a7 d1 ff ff       	call   80100f12 <filealloc>
80103d6b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d6e:	89 02                	mov    %eax,(%edx)
80103d70:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d73:	8b 00                	mov    (%eax),%eax
80103d75:	85 c0                	test   %eax,%eax
80103d77:	0f 84 b1 00 00 00    	je     80103e2e <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103d7d:	e8 c0 ee ff ff       	call   80102c42 <kalloc>
80103d82:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d89:	75 05                	jne    80103d90 <pipealloc+0x61>
    goto bad;
80103d8b:	e9 9e 00 00 00       	jmp    80103e2e <pipealloc+0xff>
  p->readopen = 1;
80103d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d93:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103d9a:	00 00 00 
  p->writeopen = 1;
80103d9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103da7:	00 00 00 
  p->nwrite = 0;
80103daa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dad:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103db4:	00 00 00 
  p->nread = 0;
80103db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dba:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103dc1:	00 00 00 
  initlock(&p->lock, "pipe");
80103dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc7:	c7 44 24 04 08 8b 10 	movl   $0x80108b08,0x4(%esp)
80103dce:	80 
80103dcf:	89 04 24             	mov    %eax,(%esp)
80103dd2:	e8 25 12 00 00       	call   80104ffc <initlock>
  (*f0)->type = FD_PIPE;
80103dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80103dda:	8b 00                	mov    (%eax),%eax
80103ddc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103de2:	8b 45 08             	mov    0x8(%ebp),%eax
80103de5:	8b 00                	mov    (%eax),%eax
80103de7:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103deb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dee:	8b 00                	mov    (%eax),%eax
80103df0:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103df4:	8b 45 08             	mov    0x8(%ebp),%eax
80103df7:	8b 00                	mov    (%eax),%eax
80103df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dfc:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103dff:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e02:	8b 00                	mov    (%eax),%eax
80103e04:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e0d:	8b 00                	mov    (%eax),%eax
80103e0f:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103e13:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e16:	8b 00                	mov    (%eax),%eax
80103e18:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e1f:	8b 00                	mov    (%eax),%eax
80103e21:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e24:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103e27:	b8 00 00 00 00       	mov    $0x0,%eax
80103e2c:	eb 42                	jmp    80103e70 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103e2e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e32:	74 0b                	je     80103e3f <pipealloc+0x110>
    kfree((char*)p);
80103e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e37:	89 04 24             	mov    %eax,(%esp)
80103e3a:	e8 6a ed ff ff       	call   80102ba9 <kfree>
  if(*f0)
80103e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e42:	8b 00                	mov    (%eax),%eax
80103e44:	85 c0                	test   %eax,%eax
80103e46:	74 0d                	je     80103e55 <pipealloc+0x126>
    fileclose(*f0);
80103e48:	8b 45 08             	mov    0x8(%ebp),%eax
80103e4b:	8b 00                	mov    (%eax),%eax
80103e4d:	89 04 24             	mov    %eax,(%esp)
80103e50:	e8 65 d1 ff ff       	call   80100fba <fileclose>
  if(*f1)
80103e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e58:	8b 00                	mov    (%eax),%eax
80103e5a:	85 c0                	test   %eax,%eax
80103e5c:	74 0d                	je     80103e6b <pipealloc+0x13c>
    fileclose(*f1);
80103e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e61:	8b 00                	mov    (%eax),%eax
80103e63:	89 04 24             	mov    %eax,(%esp)
80103e66:	e8 4f d1 ff ff       	call   80100fba <fileclose>
  return -1;
80103e6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103e70:	c9                   	leave  
80103e71:	c3                   	ret    

80103e72 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103e72:	55                   	push   %ebp
80103e73:	89 e5                	mov    %esp,%ebp
80103e75:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103e78:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7b:	89 04 24             	mov    %eax,(%esp)
80103e7e:	e8 9a 11 00 00       	call   8010501d <acquire>
  if(writable){
80103e83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103e87:	74 1f                	je     80103ea8 <pipeclose+0x36>
    p->writeopen = 0;
80103e89:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8c:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103e93:	00 00 00 
    wakeup(&p->nread);
80103e96:	8b 45 08             	mov    0x8(%ebp),%eax
80103e99:	05 34 02 00 00       	add    $0x234,%eax
80103e9e:	89 04 24             	mov    %eax,(%esp)
80103ea1:	e8 d1 0b 00 00       	call   80104a77 <wakeup>
80103ea6:	eb 1d                	jmp    80103ec5 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80103eab:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103eb2:	00 00 00 
    wakeup(&p->nwrite);
80103eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb8:	05 38 02 00 00       	add    $0x238,%eax
80103ebd:	89 04 24             	mov    %eax,(%esp)
80103ec0:	e8 b2 0b 00 00       	call   80104a77 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103ec5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103ece:	85 c0                	test   %eax,%eax
80103ed0:	75 25                	jne    80103ef7 <pipeclose+0x85>
80103ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103edb:	85 c0                	test   %eax,%eax
80103edd:	75 18                	jne    80103ef7 <pipeclose+0x85>
    release(&p->lock);
80103edf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee2:	89 04 24             	mov    %eax,(%esp)
80103ee5:	e8 95 11 00 00       	call   8010507f <release>
    kfree((char*)p);
80103eea:	8b 45 08             	mov    0x8(%ebp),%eax
80103eed:	89 04 24             	mov    %eax,(%esp)
80103ef0:	e8 b4 ec ff ff       	call   80102ba9 <kfree>
80103ef5:	eb 0b                	jmp    80103f02 <pipeclose+0x90>
  } else
    release(&p->lock);
80103ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80103efa:	89 04 24             	mov    %eax,(%esp)
80103efd:	e8 7d 11 00 00       	call   8010507f <release>
}
80103f02:	c9                   	leave  
80103f03:	c3                   	ret    

80103f04 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103f04:	55                   	push   %ebp
80103f05:	89 e5                	mov    %esp,%ebp
80103f07:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	89 04 24             	mov    %eax,(%esp)
80103f10:	e8 08 11 00 00       	call   8010501d <acquire>
  for(i = 0; i < n; i++){
80103f15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f1c:	e9 a6 00 00 00       	jmp    80103fc7 <pipewrite+0xc3>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f21:	eb 57                	jmp    80103f7a <pipewrite+0x76>
      if(p->readopen == 0 || proc->killed){
80103f23:	8b 45 08             	mov    0x8(%ebp),%eax
80103f26:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f2c:	85 c0                	test   %eax,%eax
80103f2e:	74 0d                	je     80103f3d <pipewrite+0x39>
80103f30:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103f36:	8b 40 24             	mov    0x24(%eax),%eax
80103f39:	85 c0                	test   %eax,%eax
80103f3b:	74 15                	je     80103f52 <pipewrite+0x4e>
        release(&p->lock);
80103f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80103f40:	89 04 24             	mov    %eax,(%esp)
80103f43:	e8 37 11 00 00       	call   8010507f <release>
        return -1;
80103f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f4d:	e9 9f 00 00 00       	jmp    80103ff1 <pipewrite+0xed>
      }
      wakeup(&p->nread);
80103f52:	8b 45 08             	mov    0x8(%ebp),%eax
80103f55:	05 34 02 00 00       	add    $0x234,%eax
80103f5a:	89 04 24             	mov    %eax,(%esp)
80103f5d:	e8 15 0b 00 00       	call   80104a77 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103f62:	8b 45 08             	mov    0x8(%ebp),%eax
80103f65:	8b 55 08             	mov    0x8(%ebp),%edx
80103f68:	81 c2 38 02 00 00    	add    $0x238,%edx
80103f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f72:	89 14 24             	mov    %edx,(%esp)
80103f75:	e8 21 0a 00 00       	call   8010499b <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7d:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103f83:	8b 45 08             	mov    0x8(%ebp),%eax
80103f86:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f8c:	05 00 02 00 00       	add    $0x200,%eax
80103f91:	39 c2                	cmp    %eax,%edx
80103f93:	74 8e                	je     80103f23 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103f95:	8b 45 08             	mov    0x8(%ebp),%eax
80103f98:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f9e:	8d 48 01             	lea    0x1(%eax),%ecx
80103fa1:	8b 55 08             	mov    0x8(%ebp),%edx
80103fa4:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103faa:	25 ff 01 00 00       	and    $0x1ff,%eax
80103faf:	89 c1                	mov    %eax,%ecx
80103fb1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb7:	01 d0                	add    %edx,%eax
80103fb9:	0f b6 10             	movzbl (%eax),%edx
80103fbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103fbf:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103fc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103fc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fca:	3b 45 10             	cmp    0x10(%ebp),%eax
80103fcd:	0f 8c 4e ff ff ff    	jl     80103f21 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd6:	05 34 02 00 00       	add    $0x234,%eax
80103fdb:	89 04 24             	mov    %eax,(%esp)
80103fde:	e8 94 0a 00 00       	call   80104a77 <wakeup>
  release(&p->lock);
80103fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe6:	89 04 24             	mov    %eax,(%esp)
80103fe9:	e8 91 10 00 00       	call   8010507f <release>
  return n;
80103fee:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103ff1:	c9                   	leave  
80103ff2:	c3                   	ret    

80103ff3 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ff3:	55                   	push   %ebp
80103ff4:	89 e5                	mov    %esp,%ebp
80103ff6:	53                   	push   %ebx
80103ff7:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffd:	89 04 24             	mov    %eax,(%esp)
80104000:	e8 18 10 00 00       	call   8010501d <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104005:	eb 3a                	jmp    80104041 <piperead+0x4e>
    if(proc->killed){
80104007:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010400d:	8b 40 24             	mov    0x24(%eax),%eax
80104010:	85 c0                	test   %eax,%eax
80104012:	74 15                	je     80104029 <piperead+0x36>
      release(&p->lock);
80104014:	8b 45 08             	mov    0x8(%ebp),%eax
80104017:	89 04 24             	mov    %eax,(%esp)
8010401a:	e8 60 10 00 00       	call   8010507f <release>
      return -1;
8010401f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104024:	e9 b5 00 00 00       	jmp    801040de <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104029:	8b 45 08             	mov    0x8(%ebp),%eax
8010402c:	8b 55 08             	mov    0x8(%ebp),%edx
8010402f:	81 c2 34 02 00 00    	add    $0x234,%edx
80104035:	89 44 24 04          	mov    %eax,0x4(%esp)
80104039:	89 14 24             	mov    %edx,(%esp)
8010403c:	e8 5a 09 00 00       	call   8010499b <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104041:	8b 45 08             	mov    0x8(%ebp),%eax
80104044:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010404a:	8b 45 08             	mov    0x8(%ebp),%eax
8010404d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104053:	39 c2                	cmp    %eax,%edx
80104055:	75 0d                	jne    80104064 <piperead+0x71>
80104057:	8b 45 08             	mov    0x8(%ebp),%eax
8010405a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104060:	85 c0                	test   %eax,%eax
80104062:	75 a3                	jne    80104007 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104064:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010406b:	eb 4b                	jmp    801040b8 <piperead+0xc5>
    if(p->nread == p->nwrite)
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104076:	8b 45 08             	mov    0x8(%ebp),%eax
80104079:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010407f:	39 c2                	cmp    %eax,%edx
80104081:	75 02                	jne    80104085 <piperead+0x92>
      break;
80104083:	eb 3b                	jmp    801040c0 <piperead+0xcd>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104085:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104088:	8b 45 0c             	mov    0xc(%ebp),%eax
8010408b:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010408e:	8b 45 08             	mov    0x8(%ebp),%eax
80104091:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104097:	8d 48 01             	lea    0x1(%eax),%ecx
8010409a:	8b 55 08             	mov    0x8(%ebp),%edx
8010409d:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801040a3:	25 ff 01 00 00       	and    $0x1ff,%eax
801040a8:	89 c2                	mov    %eax,%edx
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801040b2:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801040b4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040bb:	3b 45 10             	cmp    0x10(%ebp),%eax
801040be:	7c ad                	jl     8010406d <piperead+0x7a>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801040c0:	8b 45 08             	mov    0x8(%ebp),%eax
801040c3:	05 38 02 00 00       	add    $0x238,%eax
801040c8:	89 04 24             	mov    %eax,(%esp)
801040cb:	e8 a7 09 00 00       	call   80104a77 <wakeup>
  release(&p->lock);
801040d0:	8b 45 08             	mov    0x8(%ebp),%eax
801040d3:	89 04 24             	mov    %eax,(%esp)
801040d6:	e8 a4 0f 00 00       	call   8010507f <release>
  return i;
801040db:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801040de:	83 c4 24             	add    $0x24,%esp
801040e1:	5b                   	pop    %ebx
801040e2:	5d                   	pop    %ebp
801040e3:	c3                   	ret    

801040e4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801040e4:	55                   	push   %ebp
801040e5:	89 e5                	mov    %esp,%ebp
801040e7:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801040ea:	9c                   	pushf  
801040eb:	58                   	pop    %eax
801040ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801040ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801040f2:	c9                   	leave  
801040f3:	c3                   	ret    

801040f4 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801040f4:	55                   	push   %ebp
801040f5:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801040f7:	fb                   	sti    
}
801040f8:	5d                   	pop    %ebp
801040f9:	c3                   	ret    

801040fa <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801040fa:	55                   	push   %ebp
801040fb:	89 e5                	mov    %esp,%ebp
801040fd:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104100:	8b 55 08             	mov    0x8(%ebp),%edx
80104103:	8b 45 0c             	mov    0xc(%ebp),%eax
80104106:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104109:	f0 87 02             	lock xchg %eax,(%edx)
8010410c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010410f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104112:	c9                   	leave  
80104113:	c3                   	ret    

80104114 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104114:	55                   	push   %ebp
80104115:	89 e5                	mov    %esp,%ebp
80104117:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
8010411a:	c7 44 24 04 0d 8b 10 	movl   $0x80108b0d,0x4(%esp)
80104121:	80 
80104122:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104129:	e8 ce 0e 00 00       	call   80104ffc <initlock>
}
8010412e:	c9                   	leave  
8010412f:	c3                   	ret    

80104130 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104130:	55                   	push   %ebp
80104131:	89 e5                	mov    %esp,%ebp
80104133:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104136:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
8010413d:	e8 db 0e 00 00       	call   8010501d <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104142:	c7 45 f4 94 01 11 80 	movl   $0x80110194,-0xc(%ebp)
80104149:	eb 4b                	jmp    80104196 <allocproc+0x66>
    if(p->state == UNUSED)
8010414b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010414e:	8b 40 0c             	mov    0xc(%eax),%eax
80104151:	85 c0                	test   %eax,%eax
80104153:	75 3a                	jne    8010418f <allocproc+0x5f>
      goto found;
80104155:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104159:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104160:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104165:	8d 50 01             	lea    0x1(%eax),%edx
80104168:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
8010416e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104171:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104174:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
8010417b:	e8 ff 0e 00 00       	call   8010507f <release>
  if(p->arrivalTime == 0){
80104180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104183:	8b 80 14 02 00 00    	mov    0x214(%eax),%eax
80104189:	85 c0                	test   %eax,%eax
8010418b:	75 36                	jne    801041c3 <allocproc+0x93>
8010418d:	eb 26                	jmp    801041b5 <allocproc+0x85>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010418f:	81 45 f4 28 02 00 00 	addl   $0x228,-0xc(%ebp)
80104196:	81 7d f4 94 8b 11 80 	cmpl   $0x80118b94,-0xc(%ebp)
8010419d:	72 ac                	jb     8010414b <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010419f:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
801041a6:	e8 d4 0e 00 00       	call   8010507f <release>
  return 0;
801041ab:	b8 00 00 00 00       	mov    $0x0,%eax
801041b0:	e9 99 00 00 00       	jmp    8010424e <allocproc+0x11e>
found:
  p->state = EMBRYO;
  p->pid = nextpid++;
  release(&ptable.lock);
  if(p->arrivalTime == 0){
    p->arrivalTime = sys_uptime();
801041b5:	e8 ea 23 00 00       	call   801065a4 <sys_uptime>
801041ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041bd:	89 82 14 02 00 00    	mov    %eax,0x214(%edx)
  }

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801041c3:	e8 7a ea ff ff       	call   80102c42 <kalloc>
801041c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041cb:	89 42 08             	mov    %eax,0x8(%edx)
801041ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d1:	8b 40 08             	mov    0x8(%eax),%eax
801041d4:	85 c0                	test   %eax,%eax
801041d6:	75 11                	jne    801041e9 <allocproc+0xb9>
    p->state = UNUSED;
801041d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041db:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801041e2:	b8 00 00 00 00       	mov    $0x0,%eax
801041e7:	eb 65                	jmp    8010424e <allocproc+0x11e>
  }
  sp = p->kstack + KSTACKSIZE;
801041e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ec:	8b 40 08             	mov    0x8(%eax),%eax
801041ef:	05 00 10 00 00       	add    $0x1000,%eax
801041f4:	89 45 f0             	mov    %eax,-0x10(%ebp)

 

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801041f7:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801041fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104201:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104204:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104208:	ba e5 68 10 80       	mov    $0x801068e5,%edx
8010420d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104210:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104212:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104216:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104219:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010421c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010421f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104222:	8b 40 1c             	mov    0x1c(%eax),%eax
80104225:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010422c:	00 
8010422d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104234:	00 
80104235:	89 04 24             	mov    %eax,(%esp)
80104238:	e8 34 10 00 00       	call   80105271 <memset>
  p->context->eip = (uint)forkret;
8010423d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104240:	8b 40 1c             	mov    0x1c(%eax),%eax
80104243:	ba 6f 49 10 80       	mov    $0x8010496f,%edx
80104248:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010424b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010424e:	c9                   	leave  
8010424f:	c3                   	ret    

80104250 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104250:	55                   	push   %ebp
80104251:	89 e5                	mov    %esp,%ebp
80104253:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104256:	e8 d5 fe ff ff       	call   80104130 <allocproc>
8010425b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010425e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104261:	a3 6c b6 10 80       	mov    %eax,0x8010b66c
  if((p->pgdir = setupkvm()) == 0)
80104266:	e8 6e 3d 00 00       	call   80107fd9 <setupkvm>
8010426b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010426e:	89 42 04             	mov    %eax,0x4(%edx)
80104271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104274:	8b 40 04             	mov    0x4(%eax),%eax
80104277:	85 c0                	test   %eax,%eax
80104279:	75 0c                	jne    80104287 <userinit+0x37>
    panic("userinit: out of memory?");
8010427b:	c7 04 24 14 8b 10 80 	movl   $0x80108b14,(%esp)
80104282:	e8 b3 c2 ff ff       	call   8010053a <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104287:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010428c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428f:	8b 40 04             	mov    0x4(%eax),%eax
80104292:	89 54 24 08          	mov    %edx,0x8(%esp)
80104296:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
8010429d:	80 
8010429e:	89 04 24             	mov    %eax,(%esp)
801042a1:	e8 8b 3f 00 00       	call   80108231 <inituvm>
  p->sz = PGSIZE;
801042a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801042af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b2:	8b 40 18             	mov    0x18(%eax),%eax
801042b5:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801042bc:	00 
801042bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042c4:	00 
801042c5:	89 04 24             	mov    %eax,(%esp)
801042c8:	e8 a4 0f 00 00       	call   80105271 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801042cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d0:	8b 40 18             	mov    0x18(%eax),%eax
801042d3:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801042d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042dc:	8b 40 18             	mov    0x18(%eax),%eax
801042df:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
801042e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e8:	8b 40 18             	mov    0x18(%eax),%eax
801042eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042ee:	8b 52 18             	mov    0x18(%edx),%edx
801042f1:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801042f5:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801042f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fc:	8b 40 18             	mov    0x18(%eax),%eax
801042ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104302:	8b 52 18             	mov    0x18(%edx),%edx
80104305:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104309:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010430d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104310:	8b 40 18             	mov    0x18(%eax),%eax
80104313:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010431a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010431d:	8b 40 18             	mov    0x18(%eax),%eax
80104320:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432a:	8b 40 18             	mov    0x18(%eax),%eax
8010432d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	83 c0 6c             	add    $0x6c,%eax
8010433a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104341:	00 
80104342:	c7 44 24 04 2d 8b 10 	movl   $0x80108b2d,0x4(%esp)
80104349:	80 
8010434a:	89 04 24             	mov    %eax,(%esp)
8010434d:	e8 3f 11 00 00       	call   80105491 <safestrcpy>
  p->cwd = namei("/");
80104352:	c7 04 24 36 8b 10 80 	movl   $0x80108b36,(%esp)
80104359:	e8 08 e2 ff ff       	call   80102566 <namei>
8010435e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104361:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104367:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  p->startTime = 0;
8010436e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104371:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->index =0;
80104378:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104382:	00 00 00 
  p->arrIndex = 0;
80104385:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104388:	c7 80 1c 02 00 00 00 	movl   $0x0,0x21c(%eax)
8010438f:	00 00 00 
  p->completeTime = 0;
80104392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104395:	c7 80 18 02 00 00 00 	movl   $0x0,0x218(%eax)
8010439c:	00 00 00 
  p->arrivalTime = 0;
8010439f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a2:	c7 80 14 02 00 00 00 	movl   $0x0,0x214(%eax)
801043a9:	00 00 00 
  p->thread_identifier =0;
801043ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043af:	c7 80 20 02 00 00 00 	movl   $0x0,0x220(%eax)
801043b6:	00 00 00 

}
801043b9:	c9                   	leave  
801043ba:	c3                   	ret    

801043bb <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801043bb:	55                   	push   %ebp
801043bc:	89 e5                	mov    %esp,%ebp
801043be:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
801043c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043c7:	8b 00                	mov    (%eax),%eax
801043c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801043cc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801043d0:	7e 34                	jle    80104406 <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801043d2:	8b 55 08             	mov    0x8(%ebp),%edx
801043d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d8:	01 c2                	add    %eax,%edx
801043da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043e0:	8b 40 04             	mov    0x4(%eax),%eax
801043e3:	89 54 24 08          	mov    %edx,0x8(%esp)
801043e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801043ee:	89 04 24             	mov    %eax,(%esp)
801043f1:	e8 b1 3f 00 00       	call   801083a7 <allocuvm>
801043f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043fd:	75 41                	jne    80104440 <growproc+0x85>
      return -1;
801043ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104404:	eb 58                	jmp    8010445e <growproc+0xa3>
  } else if(n < 0){
80104406:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010440a:	79 34                	jns    80104440 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010440c:	8b 55 08             	mov    0x8(%ebp),%edx
8010440f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104412:	01 c2                	add    %eax,%edx
80104414:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010441a:	8b 40 04             	mov    0x4(%eax),%eax
8010441d:	89 54 24 08          	mov    %edx,0x8(%esp)
80104421:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104424:	89 54 24 04          	mov    %edx,0x4(%esp)
80104428:	89 04 24             	mov    %eax,(%esp)
8010442b:	e8 51 40 00 00       	call   80108481 <deallocuvm>
80104430:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104433:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104437:	75 07                	jne    80104440 <growproc+0x85>
      return -1;
80104439:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010443e:	eb 1e                	jmp    8010445e <growproc+0xa3>
  }
  proc->sz = sz;
80104440:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104446:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104449:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010444b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104451:	89 04 24             	mov    %eax,(%esp)
80104454:	e8 71 3c 00 00       	call   801080ca <switchuvm>
  return 0;
80104459:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010445e:	c9                   	leave  
8010445f:	c3                   	ret    

80104460 <fork>:
// Create a new process copying process as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104460:	55                   	push   %ebp
80104461:	89 e5                	mov    %esp,%ebp
80104463:	57                   	push   %edi
80104464:	56                   	push   %esi
80104465:	53                   	push   %ebx
80104466:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104469:	e8 c2 fc ff ff       	call   80104130 <allocproc>
8010446e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104471:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104475:	75 0a                	jne    80104481 <fork+0x21>
    return -1;
80104477:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010447c:	e9 3a 01 00 00       	jmp    801045bb <fork+0x15b>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104481:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104487:	8b 10                	mov    (%eax),%edx
80104489:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010448f:	8b 40 04             	mov    0x4(%eax),%eax
80104492:	89 54 24 04          	mov    %edx,0x4(%esp)
80104496:	89 04 24             	mov    %eax,(%esp)
80104499:	e8 7f 41 00 00       	call   8010861d <copyuvm>
8010449e:	8b 55 e0             	mov    -0x20(%ebp),%edx
801044a1:	89 42 04             	mov    %eax,0x4(%edx)
801044a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044a7:	8b 40 04             	mov    0x4(%eax),%eax
801044aa:	85 c0                	test   %eax,%eax
801044ac:	75 2c                	jne    801044da <fork+0x7a>
    kfree(np->kstack);
801044ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044b1:	8b 40 08             	mov    0x8(%eax),%eax
801044b4:	89 04 24             	mov    %eax,(%esp)
801044b7:	e8 ed e6 ff ff       	call   80102ba9 <kfree>
    np->kstack = 0;
801044bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801044c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044c9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801044d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d5:	e9 e1 00 00 00       	jmp    801045bb <fork+0x15b>
  }
  np->sz = proc->sz;
801044da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044e0:	8b 10                	mov    (%eax),%edx
801044e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044e5:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801044e7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801044ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044f1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801044f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044f7:	8b 50 18             	mov    0x18(%eax),%edx
801044fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104500:	8b 40 18             	mov    0x18(%eax),%eax
80104503:	89 c3                	mov    %eax,%ebx
80104505:	b8 13 00 00 00       	mov    $0x13,%eax
8010450a:	89 d7                	mov    %edx,%edi
8010450c:	89 de                	mov    %ebx,%esi
8010450e:	89 c1                	mov    %eax,%ecx
80104510:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104512:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104515:	8b 40 18             	mov    0x18(%eax),%eax
80104518:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010451f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104526:	eb 3d                	jmp    80104565 <fork+0x105>
    if(proc->ofile[i])
80104528:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010452e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104531:	83 c2 08             	add    $0x8,%edx
80104534:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104538:	85 c0                	test   %eax,%eax
8010453a:	74 25                	je     80104561 <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
8010453c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104542:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104545:	83 c2 08             	add    $0x8,%edx
80104548:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010454c:	89 04 24             	mov    %eax,(%esp)
8010454f:	e8 1e ca ff ff       	call   80100f72 <filedup>
80104554:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104557:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010455a:	83 c1 08             	add    $0x8,%ecx
8010455d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104561:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104565:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104569:	7e bd                	jle    80104528 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010456b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104571:	8b 40 68             	mov    0x68(%eax),%eax
80104574:	89 04 24             	mov    %eax,(%esp)
80104577:	e8 99 d2 ff ff       	call   80101815 <idup>
8010457c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010457f:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104582:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104585:	8b 40 10             	mov    0x10(%eax),%eax
80104588:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
8010458b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010458e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104595:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010459b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010459e:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045a1:	83 c0 6c             	add    $0x6c,%eax
801045a4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045ab:	00 
801045ac:	89 54 24 04          	mov    %edx,0x4(%esp)
801045b0:	89 04 24             	mov    %eax,(%esp)
801045b3:	e8 d9 0e 00 00       	call   80105491 <safestrcpy>
  return pid;
801045b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801045bb:	83 c4 2c             	add    $0x2c,%esp
801045be:	5b                   	pop    %ebx
801045bf:	5e                   	pop    %esi
801045c0:	5f                   	pop    %edi
801045c1:	5d                   	pop    %ebp
801045c2:	c3                   	ret    

801045c3 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801045c3:	55                   	push   %ebp
801045c4:	89 e5                	mov    %esp,%ebp
801045c6:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801045c9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801045d0:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
801045d5:	39 c2                	cmp    %eax,%edx
801045d7:	75 0c                	jne    801045e5 <exit+0x22>
    panic("init exiting");
801045d9:	c7 04 24 38 8b 10 80 	movl   $0x80108b38,(%esp)
801045e0:	e8 55 bf ff ff       	call   8010053a <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801045e5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045ec:	eb 44                	jmp    80104632 <exit+0x6f>
    if(proc->ofile[fd]){
801045ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801045f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045f7:	83 c2 08             	add    $0x8,%edx
801045fa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045fe:	85 c0                	test   %eax,%eax
80104600:	74 2c                	je     8010462e <exit+0x6b>
      fileclose(proc->ofile[fd]);
80104602:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104608:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010460b:	83 c2 08             	add    $0x8,%edx
8010460e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104612:	89 04 24             	mov    %eax,(%esp)
80104615:	e8 a0 c9 ff ff       	call   80100fba <fileclose>
      proc->ofile[fd] = 0;
8010461a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104620:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104623:	83 c2 08             	add    $0x8,%edx
80104626:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010462d:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010462e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104632:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104636:	7e b6                	jle    801045ee <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
80104638:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010463e:	8b 40 68             	mov    0x68(%eax),%eax
80104641:	89 04 24             	mov    %eax,(%esp)
80104644:	e8 b1 d3 ff ff       	call   801019fa <iput>
  proc->cwd = 0;
80104649:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010464f:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104656:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
8010465d:	e8 bb 09 00 00       	call   8010501d <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104662:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104668:	8b 40 14             	mov    0x14(%eax),%eax
8010466b:	89 04 24             	mov    %eax,(%esp)
8010466e:	e8 c3 03 00 00       	call   80104a36 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104673:	c7 45 f4 94 01 11 80 	movl   $0x80110194,-0xc(%ebp)
8010467a:	eb 3b                	jmp    801046b7 <exit+0xf4>
    if(p->parent == proc){
8010467c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467f:	8b 50 14             	mov    0x14(%eax),%edx
80104682:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104688:	39 c2                	cmp    %eax,%edx
8010468a:	75 24                	jne    801046b0 <exit+0xed>
      p->parent = initproc;
8010468c:	8b 15 6c b6 10 80    	mov    0x8010b66c,%edx
80104692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104695:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469b:	8b 40 0c             	mov    0xc(%eax),%eax
8010469e:	83 f8 05             	cmp    $0x5,%eax
801046a1:	75 0d                	jne    801046b0 <exit+0xed>
        wakeup1(initproc);
801046a3:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
801046a8:	89 04 24             	mov    %eax,(%esp)
801046ab:	e8 86 03 00 00       	call   80104a36 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046b0:	81 45 f4 28 02 00 00 	addl   $0x228,-0xc(%ebp)
801046b7:	81 7d f4 94 8b 11 80 	cmpl   $0x80118b94,-0xc(%ebp)
801046be:	72 bc                	jb     8010467c <exit+0xb9>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
801046c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c6:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801046cd:	e8 b9 01 00 00       	call   8010488b <sched>
  panic("zombie exit");
801046d2:	c7 04 24 45 8b 10 80 	movl   $0x80108b45,(%esp)
801046d9:	e8 5c be ff ff       	call   8010053a <panic>

801046de <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801046de:	55                   	push   %ebp
801046df:	89 e5                	mov    %esp,%ebp
801046e1:	83 ec 28             	sub    $0x28,%esp
  //define process and two int variable: one is for number children and pid
  struct proc *p;
  int havekids, pid;

  //get ptable lock
  acquire(&ptable.lock);
801046e4:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
801046eb:	e8 2d 09 00 00       	call   8010501d <acquire>
  // for all processes in ptable
  for(;;){
    // Scan through table looking for zombie children.

    havekids = 0;//initialized value is 0
801046f0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046f7:	c7 45 f4 94 01 11 80 	movl   $0x80110194,-0xc(%ebp)
801046fe:	e9 9d 00 00 00       	jmp    801047a0 <wait+0xc2>
      if(p->parent != proc)
80104703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104706:	8b 50 14             	mov    0x14(%eax),%edx
80104709:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470f:	39 c2                	cmp    %eax,%edx
80104711:	74 05                	je     80104718 <wait+0x3a>
        continue;
80104713:	e9 81 00 00 00       	jmp    80104799 <wait+0xbb>
      havekids = 1;//current process is a child process
80104718:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010471f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104722:	8b 40 0c             	mov    0xc(%eax),%eax
80104725:	83 f8 05             	cmp    $0x5,%eax
80104728:	75 6f                	jne    80104799 <wait+0xbb>
        // Found one.
        //release all process attribute
        pid = p->pid;
8010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472d:	8b 40 10             	mov    0x10(%eax),%eax
80104730:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104736:	8b 40 08             	mov    0x8(%eax),%eax
80104739:	89 04 24             	mov    %eax,(%esp)
8010473c:	e8 68 e4 ff ff       	call   80102ba9 <kfree>
        p->kstack = 0;
80104741:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104744:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010474b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474e:	8b 40 04             	mov    0x4(%eax),%eax
80104751:	89 04 24             	mov    %eax,(%esp)
80104754:	e8 e4 3d 00 00       	call   8010853d <freevm>
        p->state = UNUSED;
80104759:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104766:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010476d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104770:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010477e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104781:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

        

        release(&ptable.lock);
80104788:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
8010478f:	e8 eb 08 00 00       	call   8010507f <release>

        return pid;
80104794:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104797:	eb 55                	jmp    801047ee <wait+0x110>
  // for all processes in ptable
  for(;;){
    // Scan through table looking for zombie children.

    havekids = 0;//initialized value is 0
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104799:	81 45 f4 28 02 00 00 	addl   $0x228,-0xc(%ebp)
801047a0:	81 7d f4 94 8b 11 80 	cmpl   $0x80118b94,-0xc(%ebp)
801047a7:	0f 82 56 ff ff ff    	jb     80104703 <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801047ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801047b1:	74 0d                	je     801047c0 <wait+0xe2>
801047b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b9:	8b 40 24             	mov    0x24(%eax),%eax
801047bc:	85 c0                	test   %eax,%eax
801047be:	74 13                	je     801047d3 <wait+0xf5>
      release(&ptable.lock);
801047c0:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
801047c7:	e8 b3 08 00 00       	call   8010507f <release>
      return -1;
801047cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d1:	eb 1b                	jmp    801047ee <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801047d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d9:	c7 44 24 04 60 01 11 	movl   $0x80110160,0x4(%esp)
801047e0:	80 
801047e1:	89 04 24             	mov    %eax,(%esp)
801047e4:	e8 b2 01 00 00       	call   8010499b <sleep>
  }
801047e9:	e9 02 ff ff ff       	jmp    801046f0 <wait+0x12>
}
801047ee:	c9                   	leave  
801047ef:	c3                   	ret    

801047f0 <scheduler>:
//      via swtch back to the scheduler.


void
scheduler(void)
{
801047f0:	55                   	push   %ebp
801047f1:	89 e5                	mov    %esp,%ebp
801047f3:	83 ec 28             	sub    $0x28,%esp
  // int min_burst_time;
  // int flag;

  for(;;){
    // Enable interrupts on this processor.
    sti();
801047f6:	e8 f9 f8 ff ff       	call   801040f4 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801047fb:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104802:	e8 16 08 00 00       	call   8010501d <acquire>
    
    //min_burst_time = 999999;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104807:	c7 45 f4 94 01 11 80 	movl   $0x80110194,-0xc(%ebp)
8010480e:	eb 61                	jmp    80104871 <scheduler+0x81>

        if(p->state != RUNNABLE)
80104810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104813:	8b 40 0c             	mov    0xc(%eax),%eax
80104816:	83 f8 03             	cmp    $0x3,%eax
80104819:	74 02                	je     8010481d <scheduler+0x2d>
          continue;
8010481b:	eb 4d                	jmp    8010486a <scheduler+0x7a>

        //check if there have three burst time
       // if(p->arrIndex < 3 ){
          //flag = 0;
          proc = p;
8010481d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104820:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
          switchuvm(p);
80104826:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104829:	89 04 24             	mov    %eax,(%esp)
8010482c:	e8 99 38 00 00       	call   801080ca <switchuvm>
          p->state = RUNNING;
80104831:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104834:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
          swtch(&cpu->scheduler, proc->context);
8010483b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104841:	8b 40 1c             	mov    0x1c(%eax),%eax
80104844:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010484b:	83 c2 04             	add    $0x4,%edx
8010484e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104852:	89 14 24             	mov    %edx,(%esp)
80104855:	e8 a8 0c 00 00       	call   80105502 <swtch>
          switchkvm();
8010485a:	e8 4e 38 00 00       	call   801080ad <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
          proc = 0;
8010485f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104866:	00 00 00 00 
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    
    //min_burst_time = 999999;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010486a:	81 45 f4 28 02 00 00 	addl   $0x228,-0xc(%ebp)
80104871:	81 7d f4 94 8b 11 80 	cmpl   $0x80118b94,-0xc(%ebp)
80104878:	72 96                	jb     80104810 <scheduler+0x20>
    //       // Process is done running for now.
    //       // It should have changed its p->state before coming back.
    //       proc = 0;
    // }

    release(&ptable.lock);
8010487a:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104881:	e8 f9 07 00 00       	call   8010507f <release>

  }
80104886:	e9 6b ff ff ff       	jmp    801047f6 <scheduler+0x6>

8010488b <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
8010488b:	55                   	push   %ebp
8010488c:	89 e5                	mov    %esp,%ebp
8010488e:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
80104891:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104898:	e8 aa 08 00 00       	call   80105147 <holding>
8010489d:	85 c0                	test   %eax,%eax
8010489f:	75 0c                	jne    801048ad <sched+0x22>
    panic("sched ptable.lock");
801048a1:	c7 04 24 51 8b 10 80 	movl   $0x80108b51,(%esp)
801048a8:	e8 8d bc ff ff       	call   8010053a <panic>
  if(cpu->ncli != 1)
801048ad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801048b3:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801048b9:	83 f8 01             	cmp    $0x1,%eax
801048bc:	74 0c                	je     801048ca <sched+0x3f>
    panic("sched locks");
801048be:	c7 04 24 63 8b 10 80 	movl   $0x80108b63,(%esp)
801048c5:	e8 70 bc ff ff       	call   8010053a <panic>
  if(proc->state == RUNNING)
801048ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d0:	8b 40 0c             	mov    0xc(%eax),%eax
801048d3:	83 f8 04             	cmp    $0x4,%eax
801048d6:	75 0c                	jne    801048e4 <sched+0x59>
    panic("sched running");
801048d8:	c7 04 24 6f 8b 10 80 	movl   $0x80108b6f,(%esp)
801048df:	e8 56 bc ff ff       	call   8010053a <panic>
  if(readeflags()&FL_IF)
801048e4:	e8 fb f7 ff ff       	call   801040e4 <readeflags>
801048e9:	25 00 02 00 00       	and    $0x200,%eax
801048ee:	85 c0                	test   %eax,%eax
801048f0:	74 0c                	je     801048fe <sched+0x73>
    panic("sched interruptible");
801048f2:	c7 04 24 7d 8b 10 80 	movl   $0x80108b7d,(%esp)
801048f9:	e8 3c bc ff ff       	call   8010053a <panic>
  intena = cpu->intena;
801048fe:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104904:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010490a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010490d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104913:	8b 40 04             	mov    0x4(%eax),%eax
80104916:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010491d:	83 c2 1c             	add    $0x1c,%edx
80104920:	89 44 24 04          	mov    %eax,0x4(%esp)
80104924:	89 14 24             	mov    %edx,(%esp)
80104927:	e8 d6 0b 00 00       	call   80105502 <swtch>
  cpu->intena = intena;
8010492c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104932:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104935:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010493b:	c9                   	leave  
8010493c:	c3                   	ret    

8010493d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010493d:	55                   	push   %ebp
8010493e:	89 e5                	mov    %esp,%ebp
80104940:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104943:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
8010494a:	e8 ce 06 00 00       	call   8010501d <acquire>
  proc->state = RUNNABLE;
8010494f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104955:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010495c:	e8 2a ff ff ff       	call   8010488b <sched>
  release(&ptable.lock);
80104961:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104968:	e8 12 07 00 00       	call   8010507f <release>
}
8010496d:	c9                   	leave  
8010496e:	c3                   	ret    

8010496f <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010496f:	55                   	push   %ebp
80104970:	89 e5                	mov    %esp,%ebp
80104972:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104975:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
8010497c:	e8 fe 06 00 00       	call   8010507f <release>

  if (first) {
80104981:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104986:	85 c0                	test   %eax,%eax
80104988:	74 0f                	je     80104999 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
8010498a:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104991:	00 00 00 
    initlog();
80104994:	e8 9e e7 ff ff       	call   80103137 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104999:	c9                   	leave  
8010499a:	c3                   	ret    

8010499b <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
8010499b:	55                   	push   %ebp
8010499c:	89 e5                	mov    %esp,%ebp
8010499e:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
801049a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a7:	85 c0                	test   %eax,%eax
801049a9:	75 0c                	jne    801049b7 <sleep+0x1c>
    panic("sleep");
801049ab:	c7 04 24 91 8b 10 80 	movl   $0x80108b91,(%esp)
801049b2:	e8 83 bb ff ff       	call   8010053a <panic>

  if(lk == 0)
801049b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801049bb:	75 0c                	jne    801049c9 <sleep+0x2e>
    panic("sleep without lk");
801049bd:	c7 04 24 97 8b 10 80 	movl   $0x80108b97,(%esp)
801049c4:	e8 71 bb ff ff       	call   8010053a <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801049c9:	81 7d 0c 60 01 11 80 	cmpl   $0x80110160,0xc(%ebp)
801049d0:	74 17                	je     801049e9 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
801049d2:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
801049d9:	e8 3f 06 00 00       	call   8010501d <acquire>
    release(lk);
801049de:	8b 45 0c             	mov    0xc(%ebp),%eax
801049e1:	89 04 24             	mov    %eax,(%esp)
801049e4:	e8 96 06 00 00       	call   8010507f <release>
  }

  // Go to sleep.
  proc->chan = chan;
801049e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ef:	8b 55 08             	mov    0x8(%ebp),%edx
801049f2:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
801049f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fb:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104a02:	e8 84 fe ff ff       	call   8010488b <sched>

  // Tidy up.
  proc->chan = 0;
80104a07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a0d:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104a14:	81 7d 0c 60 01 11 80 	cmpl   $0x80110160,0xc(%ebp)
80104a1b:	74 17                	je     80104a34 <sleep+0x99>
    release(&ptable.lock);
80104a1d:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104a24:	e8 56 06 00 00       	call   8010507f <release>
    acquire(lk);
80104a29:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a2c:	89 04 24             	mov    %eax,(%esp)
80104a2f:	e8 e9 05 00 00       	call   8010501d <acquire>
  }
}
80104a34:	c9                   	leave  
80104a35:	c3                   	ret    

80104a36 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104a36:	55                   	push   %ebp
80104a37:	89 e5                	mov    %esp,%ebp
80104a39:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a3c:	c7 45 fc 94 01 11 80 	movl   $0x80110194,-0x4(%ebp)
80104a43:	eb 27                	jmp    80104a6c <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104a45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a48:	8b 40 0c             	mov    0xc(%eax),%eax
80104a4b:	83 f8 02             	cmp    $0x2,%eax
80104a4e:	75 15                	jne    80104a65 <wakeup1+0x2f>
80104a50:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a53:	8b 40 20             	mov    0x20(%eax),%eax
80104a56:	3b 45 08             	cmp    0x8(%ebp),%eax
80104a59:	75 0a                	jne    80104a65 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a5e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104a65:	81 45 fc 28 02 00 00 	addl   $0x228,-0x4(%ebp)
80104a6c:	81 7d fc 94 8b 11 80 	cmpl   $0x80118b94,-0x4(%ebp)
80104a73:	72 d0                	jb     80104a45 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104a75:	c9                   	leave  
80104a76:	c3                   	ret    

80104a77 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104a77:	55                   	push   %ebp
80104a78:	89 e5                	mov    %esp,%ebp
80104a7a:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104a7d:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104a84:	e8 94 05 00 00       	call   8010501d <acquire>
  wakeup1(chan);
80104a89:	8b 45 08             	mov    0x8(%ebp),%eax
80104a8c:	89 04 24             	mov    %eax,(%esp)
80104a8f:	e8 a2 ff ff ff       	call   80104a36 <wakeup1>
  release(&ptable.lock);
80104a94:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104a9b:	e8 df 05 00 00       	call   8010507f <release>
}
80104aa0:	c9                   	leave  
80104aa1:	c3                   	ret    

80104aa2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104aa2:	55                   	push   %ebp
80104aa3:	89 e5                	mov    %esp,%ebp
80104aa5:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104aa8:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104aaf:	e8 69 05 00 00       	call   8010501d <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ab4:	c7 45 f4 94 01 11 80 	movl   $0x80110194,-0xc(%ebp)
80104abb:	eb 44                	jmp    80104b01 <kill+0x5f>
    if(p->pid == pid){
80104abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac0:	8b 40 10             	mov    0x10(%eax),%eax
80104ac3:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ac6:	75 32                	jne    80104afa <kill+0x58>
      p->killed = 1;
80104ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acb:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ad8:	83 f8 02             	cmp    $0x2,%eax
80104adb:	75 0a                	jne    80104ae7 <kill+0x45>
        p->state = RUNNABLE;
80104add:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104ae7:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104aee:	e8 8c 05 00 00       	call   8010507f <release>
      return 0;
80104af3:	b8 00 00 00 00       	mov    $0x0,%eax
80104af8:	eb 21                	jmp    80104b1b <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104afa:	81 45 f4 28 02 00 00 	addl   $0x228,-0xc(%ebp)
80104b01:	81 7d f4 94 8b 11 80 	cmpl   $0x80118b94,-0xc(%ebp)
80104b08:	72 b3                	jb     80104abd <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104b0a:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104b11:	e8 69 05 00 00       	call   8010507f <release>
  return -1;
80104b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b1b:	c9                   	leave  
80104b1c:	c3                   	ret    

80104b1d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b1d:	55                   	push   %ebp
80104b1e:	89 e5                	mov    %esp,%ebp
80104b20:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b23:	c7 45 f0 94 01 11 80 	movl   $0x80110194,-0x10(%ebp)
80104b2a:	e9 d9 00 00 00       	jmp    80104c08 <procdump+0xeb>
    if(p->state == UNUSED)
80104b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b32:	8b 40 0c             	mov    0xc(%eax),%eax
80104b35:	85 c0                	test   %eax,%eax
80104b37:	75 05                	jne    80104b3e <procdump+0x21>
      continue;
80104b39:	e9 c3 00 00 00       	jmp    80104c01 <procdump+0xe4>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b41:	8b 40 0c             	mov    0xc(%eax),%eax
80104b44:	83 f8 05             	cmp    $0x5,%eax
80104b47:	77 23                	ja     80104b6c <procdump+0x4f>
80104b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104b4f:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104b56:	85 c0                	test   %eax,%eax
80104b58:	74 12                	je     80104b6c <procdump+0x4f>
      state = states[p->state];
80104b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b5d:	8b 40 0c             	mov    0xc(%eax),%eax
80104b60:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104b67:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104b6a:	eb 07                	jmp    80104b73 <procdump+0x56>
    else
      state = "???";
80104b6c:	c7 45 ec a8 8b 10 80 	movl   $0x80108ba8,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b76:	8d 50 6c             	lea    0x6c(%eax),%edx
80104b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b7c:	8b 40 10             	mov    0x10(%eax),%eax
80104b7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104b83:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104b86:	89 54 24 08          	mov    %edx,0x8(%esp)
80104b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b8e:	c7 04 24 ac 8b 10 80 	movl   $0x80108bac,(%esp)
80104b95:	e8 06 b8 ff ff       	call   801003a0 <cprintf>
    if(p->state == SLEEPING){
80104b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b9d:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba0:	83 f8 02             	cmp    $0x2,%eax
80104ba3:	75 50                	jne    80104bf5 <procdump+0xd8>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ba5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ba8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bab:	8b 40 0c             	mov    0xc(%eax),%eax
80104bae:	83 c0 08             	add    $0x8,%eax
80104bb1:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104bb4:	89 54 24 04          	mov    %edx,0x4(%esp)
80104bb8:	89 04 24             	mov    %eax,(%esp)
80104bbb:	e8 0e 05 00 00       	call   801050ce <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104bc0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bc7:	eb 1b                	jmp    80104be4 <procdump+0xc7>
        cprintf(" %p", pc[i]);
80104bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcc:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104bd4:	c7 04 24 b5 8b 10 80 	movl   $0x80108bb5,(%esp)
80104bdb:	e8 c0 b7 ff ff       	call   801003a0 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104be0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104be4:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104be8:	7f 0b                	jg     80104bf5 <procdump+0xd8>
80104bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bed:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104bf1:	85 c0                	test   %eax,%eax
80104bf3:	75 d4                	jne    80104bc9 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104bf5:	c7 04 24 b9 8b 10 80 	movl   $0x80108bb9,(%esp)
80104bfc:	e8 9f b7 ff ff       	call   801003a0 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c01:	81 45 f0 28 02 00 00 	addl   $0x228,-0x10(%ebp)
80104c08:	81 7d f0 94 8b 11 80 	cmpl   $0x80118b94,-0x10(%ebp)
80104c0f:	0f 82 1a ff ff ff    	jb     80104b2f <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104c15:	c9                   	leave  
80104c16:	c3                   	ret    

80104c17 <thread_create>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
thread_create(void(*tmain)(void *), void *stack, void *arg)
{
80104c17:	55                   	push   %ebp
80104c18:	89 e5                	mov    %esp,%ebp
80104c1a:	57                   	push   %edi
80104c1b:	56                   	push   %esi
80104c1c:	53                   	push   %ebx
80104c1d:	83 ec 3c             	sub    $0x3c,%esp
  int i, pid;
  struct proc *np;
  
  uint sp = (uint)stack;
80104c20:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  //cprintf("spppppp%d\n", sp);
  //cprintf("argggg%d\n", &arg);
  sp = (sp - (sizeof(int))) & ~3;
80104c26:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c29:	83 e8 04             	sub    $0x4,%eax
80104c2c:	83 e0 fc             	and    $0xfffffffc,%eax
80104c2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  copyout(proc->pgdir, sp, (char *)arg, sizeof(int));
80104c32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c38:	8b 40 04             	mov    0x4(%eax),%eax
80104c3b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
80104c42:	00 
80104c43:	8b 55 10             	mov    0x10(%ebp),%edx
80104c46:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c4a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104c4d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104c51:	89 04 24             	mov    %eax,(%esp)
80104c54:	e8 43 3b 00 00       	call   8010879c <copyout>
  uint myStack[3];
  myStack[0] = 0xffffffff;  // fake return PC
80104c59:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  myStack[1] = sp;
80104c60:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104c63:	89 45 d0             	mov    %eax,-0x30(%ebp)
  myStack[2] = 0;  // argv pointer
80104c66:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  sp += 3 * 4;
80104c6d:	83 45 e0 0c          	addl   $0xc,-0x20(%ebp)
  copyout(proc->pgdir, sp, myStack, 3 * 4);
80104c71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c77:	8b 40 04             	mov    0x4(%eax),%eax
80104c7a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
80104c81:	00 
80104c82:	8d 55 cc             	lea    -0x34(%ebp),%edx
80104c85:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c89:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104c8c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104c90:	89 04 24             	mov    %eax,(%esp)
80104c93:	e8 04 3b 00 00       	call   8010879c <copyout>
  //Initcode.S begins by pushing three values on the stack - $argv, $init,and $0
  //then sets %eax to $SYS_exec and executes int $T_SYSCALL
  //uint stack_3_init_value[3];

  // Allocate process.
  if((np = allocproc()) == 0)
80104c98:	e8 93 f4 ff ff       	call   80104130 <allocproc>
80104c9d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104ca0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104ca4:	75 0a                	jne    80104cb0 <thread_create+0x99>
    return -1;
80104ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cab:	e9 21 01 00 00       	jmp    80104dd1 <thread_create+0x1ba>

  
  //different threads have same page table
  np->pgdir = proc->pgdir;
80104cb0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cb6:	8b 50 04             	mov    0x4(%eax),%edx
80104cb9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104cbc:	89 50 04             	mov    %edx,0x4(%eax)
  np->sz = proc->sz;
80104cbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cc5:	8b 10                	mov    (%eax),%edx
80104cc7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104cca:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104ccc:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104cd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104cd6:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104cd9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104cdc:	8b 50 18             	mov    0x18(%eax),%edx
80104cdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce5:	8b 40 18             	mov    0x18(%eax),%eax
80104ce8:	89 c3                	mov    %eax,%ebx
80104cea:	b8 13 00 00 00       	mov    $0x13,%eax
80104cef:	89 d7                	mov    %edx,%edi
80104cf1:	89 de                	mov    %ebx,%esi
80104cf3:	89 c1                	mov    %eax,%ecx
80104cf5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  

  np->thread_identifier = 1;
80104cf7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104cfa:	c7 80 20 02 00 00 01 	movl   $0x1,0x220(%eax)
80104d01:	00 00 00 
  np->thread_top_stack = (char *)stack;
80104d04:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104d07:	8b 55 0c             	mov    0xc(%ebp),%edx
80104d0a:	89 90 24 02 00 00    	mov    %edx,0x224(%eax)
  np->tf->esp = (uint)sp;
80104d10:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104d13:	8b 40 18             	mov    0x18(%eax),%eax
80104d16:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104d19:	89 50 44             	mov    %edx,0x44(%eax)
  np->tf->eip = (uint)tmain;
80104d1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104d1f:	8b 40 18             	mov    0x18(%eax),%eax
80104d22:	8b 55 08             	mov    0x8(%ebp),%edx
80104d25:	89 50 38             	mov    %edx,0x38(%eax)
  

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104d2b:	8b 40 18             	mov    0x18(%eax),%eax
80104d2e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  //same file handlers for the child thread
  for(i = 0; i < NOFILE; i++)
80104d35:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104d3c:	eb 3d                	jmp    80104d7b <thread_create+0x164>
    if(proc->ofile[i])
80104d3e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d47:	83 c2 08             	add    $0x8,%edx
80104d4a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d4e:	85 c0                	test   %eax,%eax
80104d50:	74 25                	je     80104d77 <thread_create+0x160>
      np->ofile[i] = filedup(proc->ofile[i]);
80104d52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d58:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d5b:	83 c2 08             	add    $0x8,%edx
80104d5e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104d62:	89 04 24             	mov    %eax,(%esp)
80104d65:	e8 08 c2 ff ff       	call   80100f72 <filedup>
80104d6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104d6d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104d70:	83 c1 08             	add    $0x8,%ecx
80104d73:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  //same file handlers for the child thread
  for(i = 0; i < NOFILE; i++)
80104d77:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104d7b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104d7f:	7e bd                	jle    80104d3e <thread_create+0x127>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
80104d81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d87:	8b 40 68             	mov    0x68(%eax),%eax
80104d8a:	89 04 24             	mov    %eax,(%esp)
80104d8d:	e8 83 ca ff ff       	call   80101815 <idup>
80104d92:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104d95:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
80104d98:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104d9b:	8b 40 10             	mov    0x10(%eax),%eax
80104d9e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  np->state = RUNNABLE;
80104da1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104da4:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104dab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104db1:	8d 50 6c             	lea    0x6c(%eax),%edx
80104db4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104db7:	83 c0 6c             	add    $0x6c,%eax
80104dba:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104dc1:	00 
80104dc2:	89 54 24 04          	mov    %edx,0x4(%esp)
80104dc6:	89 04 24             	mov    %eax,(%esp)
80104dc9:	e8 c3 06 00 00       	call   80105491 <safestrcpy>
  return pid;
80104dce:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104dd1:	83 c4 3c             	add    $0x3c,%esp
80104dd4:	5b                   	pop    %ebx
80104dd5:	5e                   	pop    %esi
80104dd6:	5f                   	pop    %edi
80104dd7:	5d                   	pop    %ebp
80104dd8:	c3                   	ret    

80104dd9 <thread_join>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
thread_join(char **stack)
{
80104dd9:	55                   	push   %ebp
80104dda:	89 e5                	mov    %esp,%ebp
80104ddc:	83 ec 28             	sub    $0x28,%esp
  //define process and two int variable: one is for number children and pid
  struct proc *p;
  int havekids, pid;

  //get ptable lock
  acquire(&ptable.lock);
80104ddf:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104de6:	e8 32 02 00 00       	call   8010501d <acquire>
  // for all processes in ptable
  for(;;){
    // Scan through table looking for zombie children.

    havekids = 0;//initialized value is 0
80104deb:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104df2:	c7 45 f4 94 01 11 80 	movl   $0x80110194,-0xc(%ebp)
80104df9:	e9 b3 00 00 00       	jmp    80104eb1 <thread_join+0xd8>
      if(p->parent != proc || p->pgdir != proc->pgdir)
80104dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e01:	8b 50 14             	mov    0x14(%eax),%edx
80104e04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e0a:	39 c2                	cmp    %eax,%edx
80104e0c:	75 13                	jne    80104e21 <thread_join+0x48>
80104e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e11:	8b 50 04             	mov    0x4(%eax),%edx
80104e14:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e1a:	8b 40 04             	mov    0x4(%eax),%eax
80104e1d:	39 c2                	cmp    %eax,%edx
80104e1f:	74 05                	je     80104e26 <thread_join+0x4d>
        continue;
80104e21:	e9 84 00 00 00       	jmp    80104eaa <thread_join+0xd1>
      //     int c =1;
      //     cprintf("stateccc%d:\n", c);
      //   }
      // }

      havekids = 1;//current process is a child process
80104e26:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE ){
80104e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e30:	8b 40 0c             	mov    0xc(%eax),%eax
80104e33:	83 f8 05             	cmp    $0x5,%eax
80104e36:	75 72                	jne    80104eaa <thread_join+0xd1>
        // Found one.
        //release all process attribute
        
        pid = p->pid;
80104e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3b:	8b 40 10             	mov    0x10(%eax),%eax
80104e3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        
        kfree(p->kstack);
80104e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e44:	8b 40 08             	mov    0x8(%eax),%eax
80104e47:	89 04 24             	mov    %eax,(%esp)
80104e4a:	e8 5a dd ff ff       	call   80102ba9 <kfree>
      
        p->kstack = 0;
80104e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
      
        //freevm(p->pgdir);
        
        p->state = UNUSED;
80104e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        //cprintf("pstateeeee%d\n", p->state);
        p->pid = 0;
80104e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e66:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e70:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e7a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e81:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)

        *stack = p->thread_top_stack -4;
80104e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8b:	8b 80 24 02 00 00    	mov    0x224(%eax),%eax
80104e91:	8d 50 fc             	lea    -0x4(%eax),%edx
80104e94:	8b 45 08             	mov    0x8(%ebp),%eax
80104e97:	89 10                	mov    %edx,(%eax)
        
        release(&ptable.lock);
80104e99:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104ea0:	e8 da 01 00 00       	call   8010507f <release>

        return pid;
80104ea5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ea8:	eb 55                	jmp    80104eff <thread_join+0x126>
  // for all processes in ptable
  for(;;){
    // Scan through table looking for zombie children.

    havekids = 0;//initialized value is 0
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104eaa:	81 45 f4 28 02 00 00 	addl   $0x228,-0xc(%ebp)
80104eb1:	81 7d f4 94 8b 11 80 	cmpl   $0x80118b94,-0xc(%ebp)
80104eb8:	0f 82 40 ff ff ff    	jb     80104dfe <thread_join+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104ebe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ec2:	74 0d                	je     80104ed1 <thread_join+0xf8>
80104ec4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eca:	8b 40 24             	mov    0x24(%eax),%eax
80104ecd:	85 c0                	test   %eax,%eax
80104ecf:	74 13                	je     80104ee4 <thread_join+0x10b>
      release(&ptable.lock);
80104ed1:	c7 04 24 60 01 11 80 	movl   $0x80110160,(%esp)
80104ed8:	e8 a2 01 00 00       	call   8010507f <release>
      return -1;
80104edd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee2:	eb 1b                	jmp    80104eff <thread_join+0x126>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104ee4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eea:	c7 44 24 04 60 01 11 	movl   $0x80110160,0x4(%esp)
80104ef1:	80 
80104ef2:	89 04 24             	mov    %eax,(%esp)
80104ef5:	e8 a1 fa ff ff       	call   8010499b <sleep>
  }
80104efa:	e9 ec fe ff ff       	jmp    80104deb <thread_join+0x12>
}
80104eff:	c9                   	leave  
80104f00:	c3                   	ret    

80104f01 <mtx_create>:

int mtx_index = 0;
struct spinlock my_mutex[10];

int 
mtx_create(int locked){
80104f01:	55                   	push   %ebp
80104f02:	89 e5                	mov    %esp,%ebp
80104f04:	83 ec 28             	sub    $0x28,%esp
  
  argint(0, &locked);
80104f07:	8d 45 08             	lea    0x8(%ebp),%eax
80104f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104f15:	e8 99 06 00 00       	call   801055b3 <argint>
  int lockId = mtx_index++;
80104f1a:	a1 68 b6 10 80       	mov    0x8010b668,%eax
80104f1f:	8d 50 01             	lea    0x1(%eax),%edx
80104f22:	89 15 68 b6 10 80    	mov    %edx,0x8010b668
80104f28:	89 45 f4             	mov    %eax,-0xc(%ebp)
  xchg(&(my_mutex[lockId].locked), locked);
80104f2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f31:	6b d2 34             	imul   $0x34,%edx,%edx
80104f34:	81 c2 40 ff 10 80    	add    $0x8010ff40,%edx
80104f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f3e:	89 14 24             	mov    %edx,(%esp)
80104f41:	e8 b4 f1 ff ff       	call   801040fa <xchg>
   //cprintf("mtx_create: lockId%d\n", lockId);
  return lockId;
80104f46:	8b 45 f4             	mov    -0xc(%ebp),%eax

}
80104f49:	c9                   	leave  
80104f4a:	c3                   	ret    

80104f4b <mtx_lock>:

int 
mtx_lock(int lock_id){
80104f4b:	55                   	push   %ebp
80104f4c:	89 e5                	mov    %esp,%ebp
80104f4e:	83 ec 18             	sub    $0x18,%esp
  argint(0, &lock_id);
80104f51:	8d 45 08             	lea    0x8(%ebp),%eax
80104f54:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104f5f:	e8 4f 06 00 00       	call   801055b3 <argint>
  while(xchg(&(my_mutex[lock_id].locked), 1) != 0);
80104f64:	90                   	nop
80104f65:	8b 45 08             	mov    0x8(%ebp),%eax
80104f68:	6b c0 34             	imul   $0x34,%eax,%eax
80104f6b:	05 40 ff 10 80       	add    $0x8010ff40,%eax
80104f70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104f77:	00 
80104f78:	89 04 24             	mov    %eax,(%esp)
80104f7b:	e8 7a f1 ff ff       	call   801040fa <xchg>
80104f80:	85 c0                	test   %eax,%eax
80104f82:	75 e1                	jne    80104f65 <mtx_lock+0x1a>
   //cprintf("mtx_lock: lockId%d\n", lock_id);
  return 0;
80104f84:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f89:	c9                   	leave  
80104f8a:	c3                   	ret    

80104f8b <mtx_unlock>:

int 
mtx_unlock(int lock_id){
80104f8b:	55                   	push   %ebp
80104f8c:	89 e5                	mov    %esp,%ebp
80104f8e:	83 ec 18             	sub    $0x18,%esp
  argint(0, &lock_id);
80104f91:	8d 45 08             	lea    0x8(%ebp),%eax
80104f94:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104f9f:	e8 0f 06 00 00       	call   801055b3 <argint>
  xchg(&(my_mutex[lock_id].locked), 0);
80104fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80104fa7:	6b c0 34             	imul   $0x34,%eax,%eax
80104faa:	05 40 ff 10 80       	add    $0x8010ff40,%eax
80104faf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104fb6:	00 
80104fb7:	89 04 24             	mov    %eax,(%esp)
80104fba:	e8 3b f1 ff ff       	call   801040fa <xchg>
   //cprintf("mtx_unlock: lockId%d\n", lock_id);
  return 0;
80104fbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fc4:	c9                   	leave  
80104fc5:	c3                   	ret    

80104fc6 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104fc6:	55                   	push   %ebp
80104fc7:	89 e5                	mov    %esp,%ebp
80104fc9:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104fcc:	9c                   	pushf  
80104fcd:	58                   	pop    %eax
80104fce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104fd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fd4:	c9                   	leave  
80104fd5:	c3                   	ret    

80104fd6 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104fd6:	55                   	push   %ebp
80104fd7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104fd9:	fa                   	cli    
}
80104fda:	5d                   	pop    %ebp
80104fdb:	c3                   	ret    

80104fdc <sti>:

static inline void
sti(void)
{
80104fdc:	55                   	push   %ebp
80104fdd:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104fdf:	fb                   	sti    
}
80104fe0:	5d                   	pop    %ebp
80104fe1:	c3                   	ret    

80104fe2 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104fe2:	55                   	push   %ebp
80104fe3:	89 e5                	mov    %esp,%ebp
80104fe5:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104fe8:	8b 55 08             	mov    0x8(%ebp),%edx
80104feb:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fee:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104ff1:	f0 87 02             	lock xchg %eax,(%edx)
80104ff4:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104ff7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ffa:	c9                   	leave  
80104ffb:	c3                   	ret    

80104ffc <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104ffc:	55                   	push   %ebp
80104ffd:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104fff:	8b 45 08             	mov    0x8(%ebp),%eax
80105002:	8b 55 0c             	mov    0xc(%ebp),%edx
80105005:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105008:	8b 45 08             	mov    0x8(%ebp),%eax
8010500b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105011:	8b 45 08             	mov    0x8(%ebp),%eax
80105014:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010501b:	5d                   	pop    %ebp
8010501c:	c3                   	ret    

8010501d <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010501d:	55                   	push   %ebp
8010501e:	89 e5                	mov    %esp,%ebp
80105020:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105023:	e8 49 01 00 00       	call   80105171 <pushcli>
  if(holding(lk))
80105028:	8b 45 08             	mov    0x8(%ebp),%eax
8010502b:	89 04 24             	mov    %eax,(%esp)
8010502e:	e8 14 01 00 00       	call   80105147 <holding>
80105033:	85 c0                	test   %eax,%eax
80105035:	74 0c                	je     80105043 <acquire+0x26>
    panic("acquire");
80105037:	c7 04 24 e5 8b 10 80 	movl   $0x80108be5,(%esp)
8010503e:	e8 f7 b4 ff ff       	call   8010053a <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105043:	90                   	nop
80105044:	8b 45 08             	mov    0x8(%ebp),%eax
80105047:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010504e:	00 
8010504f:	89 04 24             	mov    %eax,(%esp)
80105052:	e8 8b ff ff ff       	call   80104fe2 <xchg>
80105057:	85 c0                	test   %eax,%eax
80105059:	75 e9                	jne    80105044 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
8010505b:	8b 45 08             	mov    0x8(%ebp),%eax
8010505e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105065:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105068:	8b 45 08             	mov    0x8(%ebp),%eax
8010506b:	83 c0 0c             	add    $0xc,%eax
8010506e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105072:	8d 45 08             	lea    0x8(%ebp),%eax
80105075:	89 04 24             	mov    %eax,(%esp)
80105078:	e8 51 00 00 00       	call   801050ce <getcallerpcs>
}
8010507d:	c9                   	leave  
8010507e:	c3                   	ret    

8010507f <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010507f:	55                   	push   %ebp
80105080:	89 e5                	mov    %esp,%ebp
80105082:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105085:	8b 45 08             	mov    0x8(%ebp),%eax
80105088:	89 04 24             	mov    %eax,(%esp)
8010508b:	e8 b7 00 00 00       	call   80105147 <holding>
80105090:	85 c0                	test   %eax,%eax
80105092:	75 0c                	jne    801050a0 <release+0x21>
    panic("release");
80105094:	c7 04 24 ed 8b 10 80 	movl   $0x80108bed,(%esp)
8010509b:	e8 9a b4 ff ff       	call   8010053a <panic>

  lk->pcs[0] = 0;
801050a0:	8b 45 08             	mov    0x8(%ebp),%eax
801050a3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050aa:	8b 45 08             	mov    0x8(%ebp),%eax
801050ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801050b4:	8b 45 08             	mov    0x8(%ebp),%eax
801050b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801050be:	00 
801050bf:	89 04 24             	mov    %eax,(%esp)
801050c2:	e8 1b ff ff ff       	call   80104fe2 <xchg>

  popcli();
801050c7:	e8 e9 00 00 00       	call   801051b5 <popcli>
}
801050cc:	c9                   	leave  
801050cd:	c3                   	ret    

801050ce <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050ce:	55                   	push   %ebp
801050cf:	89 e5                	mov    %esp,%ebp
801050d1:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
801050d4:	8b 45 08             	mov    0x8(%ebp),%eax
801050d7:	83 e8 08             	sub    $0x8,%eax
801050da:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801050dd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801050e4:	eb 38                	jmp    8010511e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801050e6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801050ea:	74 38                	je     80105124 <getcallerpcs+0x56>
801050ec:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801050f3:	76 2f                	jbe    80105124 <getcallerpcs+0x56>
801050f5:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801050f9:	74 29                	je     80105124 <getcallerpcs+0x56>
      break;
    pcs[i] = ebp[1];     // saved %eip
801050fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801050fe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105105:	8b 45 0c             	mov    0xc(%ebp),%eax
80105108:	01 c2                	add    %eax,%edx
8010510a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010510d:	8b 40 04             	mov    0x4(%eax),%eax
80105110:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105112:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105115:	8b 00                	mov    (%eax),%eax
80105117:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010511a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010511e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105122:	7e c2                	jle    801050e6 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105124:	eb 19                	jmp    8010513f <getcallerpcs+0x71>
    pcs[i] = 0;
80105126:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105129:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105130:	8b 45 0c             	mov    0xc(%ebp),%eax
80105133:	01 d0                	add    %edx,%eax
80105135:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010513b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010513f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105143:	7e e1                	jle    80105126 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105145:	c9                   	leave  
80105146:	c3                   	ret    

80105147 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105147:	55                   	push   %ebp
80105148:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010514a:	8b 45 08             	mov    0x8(%ebp),%eax
8010514d:	8b 00                	mov    (%eax),%eax
8010514f:	85 c0                	test   %eax,%eax
80105151:	74 17                	je     8010516a <holding+0x23>
80105153:	8b 45 08             	mov    0x8(%ebp),%eax
80105156:	8b 50 08             	mov    0x8(%eax),%edx
80105159:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010515f:	39 c2                	cmp    %eax,%edx
80105161:	75 07                	jne    8010516a <holding+0x23>
80105163:	b8 01 00 00 00       	mov    $0x1,%eax
80105168:	eb 05                	jmp    8010516f <holding+0x28>
8010516a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010516f:	5d                   	pop    %ebp
80105170:	c3                   	ret    

80105171 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105171:	55                   	push   %ebp
80105172:	89 e5                	mov    %esp,%ebp
80105174:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105177:	e8 4a fe ff ff       	call   80104fc6 <readeflags>
8010517c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
8010517f:	e8 52 fe ff ff       	call   80104fd6 <cli>
  if(cpu->ncli++ == 0)
80105184:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010518b:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105191:	8d 48 01             	lea    0x1(%eax),%ecx
80105194:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010519a:	85 c0                	test   %eax,%eax
8010519c:	75 15                	jne    801051b3 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
8010519e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051a7:	81 e2 00 02 00 00    	and    $0x200,%edx
801051ad:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801051b3:	c9                   	leave  
801051b4:	c3                   	ret    

801051b5 <popcli>:

void
popcli(void)
{
801051b5:	55                   	push   %ebp
801051b6:	89 e5                	mov    %esp,%ebp
801051b8:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801051bb:	e8 06 fe ff ff       	call   80104fc6 <readeflags>
801051c0:	25 00 02 00 00       	and    $0x200,%eax
801051c5:	85 c0                	test   %eax,%eax
801051c7:	74 0c                	je     801051d5 <popcli+0x20>
    panic("popcli - interruptible");
801051c9:	c7 04 24 f5 8b 10 80 	movl   $0x80108bf5,(%esp)
801051d0:	e8 65 b3 ff ff       	call   8010053a <panic>
  if(--cpu->ncli < 0)
801051d5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051db:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
801051e1:	83 ea 01             	sub    $0x1,%edx
801051e4:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
801051ea:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801051f0:	85 c0                	test   %eax,%eax
801051f2:	79 0c                	jns    80105200 <popcli+0x4b>
    panic("popcli");
801051f4:	c7 04 24 0c 8c 10 80 	movl   $0x80108c0c,(%esp)
801051fb:	e8 3a b3 ff ff       	call   8010053a <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105200:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105206:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010520c:	85 c0                	test   %eax,%eax
8010520e:	75 15                	jne    80105225 <popcli+0x70>
80105210:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105216:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
8010521c:	85 c0                	test   %eax,%eax
8010521e:	74 05                	je     80105225 <popcli+0x70>
    sti();
80105220:	e8 b7 fd ff ff       	call   80104fdc <sti>
}
80105225:	c9                   	leave  
80105226:	c3                   	ret    

80105227 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105227:	55                   	push   %ebp
80105228:	89 e5                	mov    %esp,%ebp
8010522a:	57                   	push   %edi
8010522b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010522c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010522f:	8b 55 10             	mov    0x10(%ebp),%edx
80105232:	8b 45 0c             	mov    0xc(%ebp),%eax
80105235:	89 cb                	mov    %ecx,%ebx
80105237:	89 df                	mov    %ebx,%edi
80105239:	89 d1                	mov    %edx,%ecx
8010523b:	fc                   	cld    
8010523c:	f3 aa                	rep stos %al,%es:(%edi)
8010523e:	89 ca                	mov    %ecx,%edx
80105240:	89 fb                	mov    %edi,%ebx
80105242:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105245:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105248:	5b                   	pop    %ebx
80105249:	5f                   	pop    %edi
8010524a:	5d                   	pop    %ebp
8010524b:	c3                   	ret    

8010524c <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010524c:	55                   	push   %ebp
8010524d:	89 e5                	mov    %esp,%ebp
8010524f:	57                   	push   %edi
80105250:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105251:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105254:	8b 55 10             	mov    0x10(%ebp),%edx
80105257:	8b 45 0c             	mov    0xc(%ebp),%eax
8010525a:	89 cb                	mov    %ecx,%ebx
8010525c:	89 df                	mov    %ebx,%edi
8010525e:	89 d1                	mov    %edx,%ecx
80105260:	fc                   	cld    
80105261:	f3 ab                	rep stos %eax,%es:(%edi)
80105263:	89 ca                	mov    %ecx,%edx
80105265:	89 fb                	mov    %edi,%ebx
80105267:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010526a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010526d:	5b                   	pop    %ebx
8010526e:	5f                   	pop    %edi
8010526f:	5d                   	pop    %ebp
80105270:	c3                   	ret    

80105271 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105271:	55                   	push   %ebp
80105272:	89 e5                	mov    %esp,%ebp
80105274:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105277:	8b 45 08             	mov    0x8(%ebp),%eax
8010527a:	83 e0 03             	and    $0x3,%eax
8010527d:	85 c0                	test   %eax,%eax
8010527f:	75 49                	jne    801052ca <memset+0x59>
80105281:	8b 45 10             	mov    0x10(%ebp),%eax
80105284:	83 e0 03             	and    $0x3,%eax
80105287:	85 c0                	test   %eax,%eax
80105289:	75 3f                	jne    801052ca <memset+0x59>
    c &= 0xFF;
8010528b:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105292:	8b 45 10             	mov    0x10(%ebp),%eax
80105295:	c1 e8 02             	shr    $0x2,%eax
80105298:	89 c2                	mov    %eax,%edx
8010529a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010529d:	c1 e0 18             	shl    $0x18,%eax
801052a0:	89 c1                	mov    %eax,%ecx
801052a2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a5:	c1 e0 10             	shl    $0x10,%eax
801052a8:	09 c1                	or     %eax,%ecx
801052aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ad:	c1 e0 08             	shl    $0x8,%eax
801052b0:	09 c8                	or     %ecx,%eax
801052b2:	0b 45 0c             	or     0xc(%ebp),%eax
801052b5:	89 54 24 08          	mov    %edx,0x8(%esp)
801052b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801052bd:	8b 45 08             	mov    0x8(%ebp),%eax
801052c0:	89 04 24             	mov    %eax,(%esp)
801052c3:	e8 84 ff ff ff       	call   8010524c <stosl>
801052c8:	eb 19                	jmp    801052e3 <memset+0x72>
  } else
    stosb(dst, c, n);
801052ca:	8b 45 10             	mov    0x10(%ebp),%eax
801052cd:	89 44 24 08          	mov    %eax,0x8(%esp)
801052d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801052d8:	8b 45 08             	mov    0x8(%ebp),%eax
801052db:	89 04 24             	mov    %eax,(%esp)
801052de:	e8 44 ff ff ff       	call   80105227 <stosb>
  return dst;
801052e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801052e6:	c9                   	leave  
801052e7:	c3                   	ret    

801052e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801052e8:	55                   	push   %ebp
801052e9:	89 e5                	mov    %esp,%ebp
801052eb:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
801052ee:	8b 45 08             	mov    0x8(%ebp),%eax
801052f1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801052f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801052f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
801052fa:	eb 30                	jmp    8010532c <memcmp+0x44>
    if(*s1 != *s2)
801052fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052ff:	0f b6 10             	movzbl (%eax),%edx
80105302:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105305:	0f b6 00             	movzbl (%eax),%eax
80105308:	38 c2                	cmp    %al,%dl
8010530a:	74 18                	je     80105324 <memcmp+0x3c>
      return *s1 - *s2;
8010530c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010530f:	0f b6 00             	movzbl (%eax),%eax
80105312:	0f b6 d0             	movzbl %al,%edx
80105315:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105318:	0f b6 00             	movzbl (%eax),%eax
8010531b:	0f b6 c0             	movzbl %al,%eax
8010531e:	29 c2                	sub    %eax,%edx
80105320:	89 d0                	mov    %edx,%eax
80105322:	eb 1a                	jmp    8010533e <memcmp+0x56>
    s1++, s2++;
80105324:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105328:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010532c:	8b 45 10             	mov    0x10(%ebp),%eax
8010532f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105332:	89 55 10             	mov    %edx,0x10(%ebp)
80105335:	85 c0                	test   %eax,%eax
80105337:	75 c3                	jne    801052fc <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105339:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010533e:	c9                   	leave  
8010533f:	c3                   	ret    

80105340 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105346:	8b 45 0c             	mov    0xc(%ebp),%eax
80105349:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
8010534c:	8b 45 08             	mov    0x8(%ebp),%eax
8010534f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105352:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105355:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105358:	73 3d                	jae    80105397 <memmove+0x57>
8010535a:	8b 45 10             	mov    0x10(%ebp),%eax
8010535d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105360:	01 d0                	add    %edx,%eax
80105362:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105365:	76 30                	jbe    80105397 <memmove+0x57>
    s += n;
80105367:	8b 45 10             	mov    0x10(%ebp),%eax
8010536a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
8010536d:	8b 45 10             	mov    0x10(%ebp),%eax
80105370:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105373:	eb 13                	jmp    80105388 <memmove+0x48>
      *--d = *--s;
80105375:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105379:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
8010537d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105380:	0f b6 10             	movzbl (%eax),%edx
80105383:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105386:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105388:	8b 45 10             	mov    0x10(%ebp),%eax
8010538b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010538e:	89 55 10             	mov    %edx,0x10(%ebp)
80105391:	85 c0                	test   %eax,%eax
80105393:	75 e0                	jne    80105375 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105395:	eb 26                	jmp    801053bd <memmove+0x7d>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105397:	eb 17                	jmp    801053b0 <memmove+0x70>
      *d++ = *s++;
80105399:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010539c:	8d 50 01             	lea    0x1(%eax),%edx
8010539f:	89 55 f8             	mov    %edx,-0x8(%ebp)
801053a2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053a5:	8d 4a 01             	lea    0x1(%edx),%ecx
801053a8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801053ab:	0f b6 12             	movzbl (%edx),%edx
801053ae:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801053b0:	8b 45 10             	mov    0x10(%ebp),%eax
801053b3:	8d 50 ff             	lea    -0x1(%eax),%edx
801053b6:	89 55 10             	mov    %edx,0x10(%ebp)
801053b9:	85 c0                	test   %eax,%eax
801053bb:	75 dc                	jne    80105399 <memmove+0x59>
      *d++ = *s++;

  return dst;
801053bd:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053c0:	c9                   	leave  
801053c1:	c3                   	ret    

801053c2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053c2:	55                   	push   %ebp
801053c3:	89 e5                	mov    %esp,%ebp
801053c5:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
801053c8:	8b 45 10             	mov    0x10(%ebp),%eax
801053cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801053cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801053d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801053d6:	8b 45 08             	mov    0x8(%ebp),%eax
801053d9:	89 04 24             	mov    %eax,(%esp)
801053dc:	e8 5f ff ff ff       	call   80105340 <memmove>
}
801053e1:	c9                   	leave  
801053e2:	c3                   	ret    

801053e3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053e3:	55                   	push   %ebp
801053e4:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
801053e6:	eb 0c                	jmp    801053f4 <strncmp+0x11>
    n--, p++, q++;
801053e8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801053ec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
801053f0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
801053f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801053f8:	74 1a                	je     80105414 <strncmp+0x31>
801053fa:	8b 45 08             	mov    0x8(%ebp),%eax
801053fd:	0f b6 00             	movzbl (%eax),%eax
80105400:	84 c0                	test   %al,%al
80105402:	74 10                	je     80105414 <strncmp+0x31>
80105404:	8b 45 08             	mov    0x8(%ebp),%eax
80105407:	0f b6 10             	movzbl (%eax),%edx
8010540a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010540d:	0f b6 00             	movzbl (%eax),%eax
80105410:	38 c2                	cmp    %al,%dl
80105412:	74 d4                	je     801053e8 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105414:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105418:	75 07                	jne    80105421 <strncmp+0x3e>
    return 0;
8010541a:	b8 00 00 00 00       	mov    $0x0,%eax
8010541f:	eb 16                	jmp    80105437 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105421:	8b 45 08             	mov    0x8(%ebp),%eax
80105424:	0f b6 00             	movzbl (%eax),%eax
80105427:	0f b6 d0             	movzbl %al,%edx
8010542a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010542d:	0f b6 00             	movzbl (%eax),%eax
80105430:	0f b6 c0             	movzbl %al,%eax
80105433:	29 c2                	sub    %eax,%edx
80105435:	89 d0                	mov    %edx,%eax
}
80105437:	5d                   	pop    %ebp
80105438:	c3                   	ret    

80105439 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105439:	55                   	push   %ebp
8010543a:	89 e5                	mov    %esp,%ebp
8010543c:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010543f:	8b 45 08             	mov    0x8(%ebp),%eax
80105442:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105445:	90                   	nop
80105446:	8b 45 10             	mov    0x10(%ebp),%eax
80105449:	8d 50 ff             	lea    -0x1(%eax),%edx
8010544c:	89 55 10             	mov    %edx,0x10(%ebp)
8010544f:	85 c0                	test   %eax,%eax
80105451:	7e 1e                	jle    80105471 <strncpy+0x38>
80105453:	8b 45 08             	mov    0x8(%ebp),%eax
80105456:	8d 50 01             	lea    0x1(%eax),%edx
80105459:	89 55 08             	mov    %edx,0x8(%ebp)
8010545c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010545f:	8d 4a 01             	lea    0x1(%edx),%ecx
80105462:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105465:	0f b6 12             	movzbl (%edx),%edx
80105468:	88 10                	mov    %dl,(%eax)
8010546a:	0f b6 00             	movzbl (%eax),%eax
8010546d:	84 c0                	test   %al,%al
8010546f:	75 d5                	jne    80105446 <strncpy+0xd>
    ;
  while(n-- > 0)
80105471:	eb 0c                	jmp    8010547f <strncpy+0x46>
    *s++ = 0;
80105473:	8b 45 08             	mov    0x8(%ebp),%eax
80105476:	8d 50 01             	lea    0x1(%eax),%edx
80105479:	89 55 08             	mov    %edx,0x8(%ebp)
8010547c:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
8010547f:	8b 45 10             	mov    0x10(%ebp),%eax
80105482:	8d 50 ff             	lea    -0x1(%eax),%edx
80105485:	89 55 10             	mov    %edx,0x10(%ebp)
80105488:	85 c0                	test   %eax,%eax
8010548a:	7f e7                	jg     80105473 <strncpy+0x3a>
    *s++ = 0;
  return os;
8010548c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010548f:	c9                   	leave  
80105490:	c3                   	ret    

80105491 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105491:	55                   	push   %ebp
80105492:	89 e5                	mov    %esp,%ebp
80105494:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105497:	8b 45 08             	mov    0x8(%ebp),%eax
8010549a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010549d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054a1:	7f 05                	jg     801054a8 <safestrcpy+0x17>
    return os;
801054a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054a6:	eb 31                	jmp    801054d9 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
801054a8:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054b0:	7e 1e                	jle    801054d0 <safestrcpy+0x3f>
801054b2:	8b 45 08             	mov    0x8(%ebp),%eax
801054b5:	8d 50 01             	lea    0x1(%eax),%edx
801054b8:	89 55 08             	mov    %edx,0x8(%ebp)
801054bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801054be:	8d 4a 01             	lea    0x1(%edx),%ecx
801054c1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801054c4:	0f b6 12             	movzbl (%edx),%edx
801054c7:	88 10                	mov    %dl,(%eax)
801054c9:	0f b6 00             	movzbl (%eax),%eax
801054cc:	84 c0                	test   %al,%al
801054ce:	75 d8                	jne    801054a8 <safestrcpy+0x17>
    ;
  *s = 0;
801054d0:	8b 45 08             	mov    0x8(%ebp),%eax
801054d3:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054d9:	c9                   	leave  
801054da:	c3                   	ret    

801054db <strlen>:

int
strlen(const char *s)
{
801054db:	55                   	push   %ebp
801054dc:	89 e5                	mov    %esp,%ebp
801054de:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054e1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801054e8:	eb 04                	jmp    801054ee <strlen+0x13>
801054ea:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054f1:	8b 45 08             	mov    0x8(%ebp),%eax
801054f4:	01 d0                	add    %edx,%eax
801054f6:	0f b6 00             	movzbl (%eax),%eax
801054f9:	84 c0                	test   %al,%al
801054fb:	75 ed                	jne    801054ea <strlen+0xf>
    ;
  return n;
801054fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105500:	c9                   	leave  
80105501:	c3                   	ret    

80105502 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105502:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105506:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010550a:	55                   	push   %ebp
  pushl %ebx
8010550b:	53                   	push   %ebx
  pushl %esi
8010550c:	56                   	push   %esi
  pushl %edi
8010550d:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010550e:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105510:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105512:	5f                   	pop    %edi
  popl %esi
80105513:	5e                   	pop    %esi
  popl %ebx
80105514:	5b                   	pop    %ebx
  popl %ebp
80105515:	5d                   	pop    %ebp
  ret
80105516:	c3                   	ret    

80105517 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105517:	55                   	push   %ebp
80105518:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010551a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105520:	8b 00                	mov    (%eax),%eax
80105522:	3b 45 08             	cmp    0x8(%ebp),%eax
80105525:	76 12                	jbe    80105539 <fetchint+0x22>
80105527:	8b 45 08             	mov    0x8(%ebp),%eax
8010552a:	8d 50 04             	lea    0x4(%eax),%edx
8010552d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105533:	8b 00                	mov    (%eax),%eax
80105535:	39 c2                	cmp    %eax,%edx
80105537:	76 07                	jbe    80105540 <fetchint+0x29>
    return -1;
80105539:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010553e:	eb 0f                	jmp    8010554f <fetchint+0x38>
  *ip = *(int*)(addr);
80105540:	8b 45 08             	mov    0x8(%ebp),%eax
80105543:	8b 10                	mov    (%eax),%edx
80105545:	8b 45 0c             	mov    0xc(%ebp),%eax
80105548:	89 10                	mov    %edx,(%eax)
  return 0;
8010554a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010554f:	5d                   	pop    %ebp
80105550:	c3                   	ret    

80105551 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105551:	55                   	push   %ebp
80105552:	89 e5                	mov    %esp,%ebp
80105554:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105557:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010555d:	8b 00                	mov    (%eax),%eax
8010555f:	3b 45 08             	cmp    0x8(%ebp),%eax
80105562:	77 07                	ja     8010556b <fetchstr+0x1a>
    return -1;
80105564:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105569:	eb 46                	jmp    801055b1 <fetchstr+0x60>
  *pp = (char*)addr;
8010556b:	8b 55 08             	mov    0x8(%ebp),%edx
8010556e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105571:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105573:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105579:	8b 00                	mov    (%eax),%eax
8010557b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010557e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105581:	8b 00                	mov    (%eax),%eax
80105583:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105586:	eb 1c                	jmp    801055a4 <fetchstr+0x53>
    if(*s == 0)
80105588:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010558b:	0f b6 00             	movzbl (%eax),%eax
8010558e:	84 c0                	test   %al,%al
80105590:	75 0e                	jne    801055a0 <fetchstr+0x4f>
      return s - *pp;
80105592:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105595:	8b 45 0c             	mov    0xc(%ebp),%eax
80105598:	8b 00                	mov    (%eax),%eax
8010559a:	29 c2                	sub    %eax,%edx
8010559c:	89 d0                	mov    %edx,%eax
8010559e:	eb 11                	jmp    801055b1 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801055a0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055a7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055aa:	72 dc                	jb     80105588 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801055ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055b1:	c9                   	leave  
801055b2:	c3                   	ret    

801055b3 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055b3:	55                   	push   %ebp
801055b4:	89 e5                	mov    %esp,%ebp
801055b6:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055bf:	8b 40 18             	mov    0x18(%eax),%eax
801055c2:	8b 50 44             	mov    0x44(%eax),%edx
801055c5:	8b 45 08             	mov    0x8(%ebp),%eax
801055c8:	c1 e0 02             	shl    $0x2,%eax
801055cb:	01 d0                	add    %edx,%eax
801055cd:	8d 50 04             	lea    0x4(%eax),%edx
801055d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801055d7:	89 14 24             	mov    %edx,(%esp)
801055da:	e8 38 ff ff ff       	call   80105517 <fetchint>
}
801055df:	c9                   	leave  
801055e0:	c3                   	ret    

801055e1 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055e1:	55                   	push   %ebp
801055e2:	89 e5                	mov    %esp,%ebp
801055e4:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
801055e7:	8d 45 fc             	lea    -0x4(%ebp),%eax
801055ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ee:	8b 45 08             	mov    0x8(%ebp),%eax
801055f1:	89 04 24             	mov    %eax,(%esp)
801055f4:	e8 ba ff ff ff       	call   801055b3 <argint>
801055f9:	85 c0                	test   %eax,%eax
801055fb:	79 07                	jns    80105604 <argptr+0x23>
    return -1;
801055fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105602:	eb 3d                	jmp    80105641 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105604:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105607:	89 c2                	mov    %eax,%edx
80105609:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010560f:	8b 00                	mov    (%eax),%eax
80105611:	39 c2                	cmp    %eax,%edx
80105613:	73 16                	jae    8010562b <argptr+0x4a>
80105615:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105618:	89 c2                	mov    %eax,%edx
8010561a:	8b 45 10             	mov    0x10(%ebp),%eax
8010561d:	01 c2                	add    %eax,%edx
8010561f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105625:	8b 00                	mov    (%eax),%eax
80105627:	39 c2                	cmp    %eax,%edx
80105629:	76 07                	jbe    80105632 <argptr+0x51>
    return -1;
8010562b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105630:	eb 0f                	jmp    80105641 <argptr+0x60>
  *pp = (char*)i;
80105632:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105635:	89 c2                	mov    %eax,%edx
80105637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563a:	89 10                	mov    %edx,(%eax)
  return 0;
8010563c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105641:	c9                   	leave  
80105642:	c3                   	ret    

80105643 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105643:	55                   	push   %ebp
80105644:	89 e5                	mov    %esp,%ebp
80105646:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105649:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010564c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105650:	8b 45 08             	mov    0x8(%ebp),%eax
80105653:	89 04 24             	mov    %eax,(%esp)
80105656:	e8 58 ff ff ff       	call   801055b3 <argint>
8010565b:	85 c0                	test   %eax,%eax
8010565d:	79 07                	jns    80105666 <argstr+0x23>
    return -1;
8010565f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105664:	eb 12                	jmp    80105678 <argstr+0x35>
  return fetchstr(addr, pp);
80105666:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105669:	8b 55 0c             	mov    0xc(%ebp),%edx
8010566c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105670:	89 04 24             	mov    %eax,(%esp)
80105673:	e8 d9 fe ff ff       	call   80105551 <fetchstr>
}
80105678:	c9                   	leave  
80105679:	c3                   	ret    

8010567a <syscall>:
[SYS_mtx_unlock]      sys_mtx_unlock,
};

void
syscall(void)
{
8010567a:	55                   	push   %ebp
8010567b:	89 e5                	mov    %esp,%ebp
8010567d:	53                   	push   %ebx
8010567e:	83 ec 24             	sub    $0x24,%esp
  int num;
  num = proc->tf->eax;
80105681:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105687:	8b 40 18             	mov    0x18(%eax),%eax
8010568a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010568d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105690:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105694:	7e 3a                	jle    801056d0 <syscall+0x56>
80105696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105699:	83 f8 1d             	cmp    $0x1d,%eax
8010569c:	77 32                	ja     801056d0 <syscall+0x56>
8010569e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a1:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056a8:	85 c0                	test   %eax,%eax
801056aa:	74 24                	je     801056d0 <syscall+0x56>
    
    sys_endBurst();
801056ac:	e8 3d 0f 00 00       	call   801065ee <sys_endBurst>
    
    proc->tf->eax = syscalls[num]();
801056b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056b7:	8b 58 18             	mov    0x18(%eax),%ebx
801056ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056bd:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056c4:	ff d0                	call   *%eax
801056c6:	89 43 1c             	mov    %eax,0x1c(%ebx)
   
    sys_startBurst();
801056c9:	e8 01 0f 00 00       	call   801065cf <sys_startBurst>
801056ce:	eb 3d                	jmp    8010570d <syscall+0x93>
 
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d6:	8d 48 6c             	lea    0x6c(%eax),%ecx
801056d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    proc->tf->eax = syscalls[num]();
   
    sys_startBurst();
 
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801056df:	8b 40 10             	mov    0x10(%eax),%eax
801056e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
801056e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801056ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801056f1:	c7 04 24 13 8c 10 80 	movl   $0x80108c13,(%esp)
801056f8:	e8 a3 ac ff ff       	call   801003a0 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
801056fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105703:	8b 40 18             	mov    0x18(%eax),%eax
80105706:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
  

}
8010570d:	83 c4 24             	add    $0x24,%esp
80105710:	5b                   	pop    %ebx
80105711:	5d                   	pop    %ebp
80105712:	c3                   	ret    

80105713 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105713:	55                   	push   %ebp
80105714:	89 e5                	mov    %esp,%ebp
80105716:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105719:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010571c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105720:	8b 45 08             	mov    0x8(%ebp),%eax
80105723:	89 04 24             	mov    %eax,(%esp)
80105726:	e8 88 fe ff ff       	call   801055b3 <argint>
8010572b:	85 c0                	test   %eax,%eax
8010572d:	79 07                	jns    80105736 <argfd+0x23>
    return -1;
8010572f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105734:	eb 50                	jmp    80105786 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105736:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105739:	85 c0                	test   %eax,%eax
8010573b:	78 21                	js     8010575e <argfd+0x4b>
8010573d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105740:	83 f8 0f             	cmp    $0xf,%eax
80105743:	7f 19                	jg     8010575e <argfd+0x4b>
80105745:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010574b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010574e:	83 c2 08             	add    $0x8,%edx
80105751:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105755:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105758:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010575c:	75 07                	jne    80105765 <argfd+0x52>
    return -1;
8010575e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105763:	eb 21                	jmp    80105786 <argfd+0x73>
  if(pfd)
80105765:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105769:	74 08                	je     80105773 <argfd+0x60>
    *pfd = fd;
8010576b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010576e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105771:	89 10                	mov    %edx,(%eax)
  if(pf)
80105773:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105777:	74 08                	je     80105781 <argfd+0x6e>
    *pf = f;
80105779:	8b 45 10             	mov    0x10(%ebp),%eax
8010577c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010577f:	89 10                	mov    %edx,(%eax)
  return 0;
80105781:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105786:	c9                   	leave  
80105787:	c3                   	ret    

80105788 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105788:	55                   	push   %ebp
80105789:	89 e5                	mov    %esp,%ebp
8010578b:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010578e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105795:	eb 30                	jmp    801057c7 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105797:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010579d:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057a0:	83 c2 08             	add    $0x8,%edx
801057a3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057a7:	85 c0                	test   %eax,%eax
801057a9:	75 18                	jne    801057c3 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057b4:	8d 4a 08             	lea    0x8(%edx),%ecx
801057b7:	8b 55 08             	mov    0x8(%ebp),%edx
801057ba:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c1:	eb 0f                	jmp    801057d2 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057c3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057c7:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057cb:	7e ca                	jle    80105797 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801057cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057d2:	c9                   	leave  
801057d3:	c3                   	ret    

801057d4 <sys_dup>:

int
sys_dup(void)
{
801057d4:	55                   	push   %ebp
801057d5:	89 e5                	mov    %esp,%ebp
801057d7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057da:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057dd:	89 44 24 08          	mov    %eax,0x8(%esp)
801057e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801057e8:	00 
801057e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801057f0:	e8 1e ff ff ff       	call   80105713 <argfd>
801057f5:	85 c0                	test   %eax,%eax
801057f7:	79 07                	jns    80105800 <sys_dup+0x2c>
    return -1;
801057f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057fe:	eb 29                	jmp    80105829 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105800:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105803:	89 04 24             	mov    %eax,(%esp)
80105806:	e8 7d ff ff ff       	call   80105788 <fdalloc>
8010580b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010580e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105812:	79 07                	jns    8010581b <sys_dup+0x47>
    return -1;
80105814:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105819:	eb 0e                	jmp    80105829 <sys_dup+0x55>
  filedup(f);
8010581b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010581e:	89 04 24             	mov    %eax,(%esp)
80105821:	e8 4c b7 ff ff       	call   80100f72 <filedup>
  return fd;
80105826:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105829:	c9                   	leave  
8010582a:	c3                   	ret    

8010582b <sys_read>:

int
sys_read(void)
{
8010582b:	55                   	push   %ebp
8010582c:	89 e5                	mov    %esp,%ebp
8010582e:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105831:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105834:	89 44 24 08          	mov    %eax,0x8(%esp)
80105838:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010583f:	00 
80105840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105847:	e8 c7 fe ff ff       	call   80105713 <argfd>
8010584c:	85 c0                	test   %eax,%eax
8010584e:	78 35                	js     80105885 <sys_read+0x5a>
80105850:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105853:	89 44 24 04          	mov    %eax,0x4(%esp)
80105857:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010585e:	e8 50 fd ff ff       	call   801055b3 <argint>
80105863:	85 c0                	test   %eax,%eax
80105865:	78 1e                	js     80105885 <sys_read+0x5a>
80105867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010586e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105871:	89 44 24 04          	mov    %eax,0x4(%esp)
80105875:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010587c:	e8 60 fd ff ff       	call   801055e1 <argptr>
80105881:	85 c0                	test   %eax,%eax
80105883:	79 07                	jns    8010588c <sys_read+0x61>
    return -1;
80105885:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588a:	eb 19                	jmp    801058a5 <sys_read+0x7a>
  return fileread(f, p, n);
8010588c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010588f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105892:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105895:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105899:	89 54 24 04          	mov    %edx,0x4(%esp)
8010589d:	89 04 24             	mov    %eax,(%esp)
801058a0:	e8 3a b8 ff ff       	call   801010df <fileread>
}
801058a5:	c9                   	leave  
801058a6:	c3                   	ret    

801058a7 <sys_write>:

int
sys_write(void)
{
801058a7:	55                   	push   %ebp
801058a8:	89 e5                	mov    %esp,%ebp
801058aa:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801058b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801058bb:	00 
801058bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801058c3:	e8 4b fe ff ff       	call   80105713 <argfd>
801058c8:	85 c0                	test   %eax,%eax
801058ca:	78 35                	js     80105901 <sys_write+0x5a>
801058cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801058d3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801058da:	e8 d4 fc ff ff       	call   801055b3 <argint>
801058df:	85 c0                	test   %eax,%eax
801058e1:	78 1e                	js     80105901 <sys_write+0x5a>
801058e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e6:	89 44 24 08          	mov    %eax,0x8(%esp)
801058ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801058f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801058f8:	e8 e4 fc ff ff       	call   801055e1 <argptr>
801058fd:	85 c0                	test   %eax,%eax
801058ff:	79 07                	jns    80105908 <sys_write+0x61>
    return -1;
80105901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105906:	eb 19                	jmp    80105921 <sys_write+0x7a>
  return filewrite(f, p, n);
80105908:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010590b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010590e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105911:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105915:	89 54 24 04          	mov    %edx,0x4(%esp)
80105919:	89 04 24             	mov    %eax,(%esp)
8010591c:	e8 7a b8 ff ff       	call   8010119b <filewrite>
}
80105921:	c9                   	leave  
80105922:	c3                   	ret    

80105923 <sys_close>:

int
sys_close(void)
{
80105923:	55                   	push   %ebp
80105924:	89 e5                	mov    %esp,%ebp
80105926:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105929:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010592c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105930:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105933:	89 44 24 04          	mov    %eax,0x4(%esp)
80105937:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010593e:	e8 d0 fd ff ff       	call   80105713 <argfd>
80105943:	85 c0                	test   %eax,%eax
80105945:	79 07                	jns    8010594e <sys_close+0x2b>
    return -1;
80105947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594c:	eb 24                	jmp    80105972 <sys_close+0x4f>
  proc->ofile[fd] = 0;
8010594e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105954:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105957:	83 c2 08             	add    $0x8,%edx
8010595a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105961:	00 
  fileclose(f);
80105962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105965:	89 04 24             	mov    %eax,(%esp)
80105968:	e8 4d b6 ff ff       	call   80100fba <fileclose>
  return 0;
8010596d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105972:	c9                   	leave  
80105973:	c3                   	ret    

80105974 <sys_fstat>:

int
sys_fstat(void)
{
80105974:	55                   	push   %ebp
80105975:	89 e5                	mov    %esp,%ebp
80105977:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010597a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010597d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105981:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105988:	00 
80105989:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105990:	e8 7e fd ff ff       	call   80105713 <argfd>
80105995:	85 c0                	test   %eax,%eax
80105997:	78 1f                	js     801059b8 <sys_fstat+0x44>
80105999:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801059a0:	00 
801059a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801059a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059af:	e8 2d fc ff ff       	call   801055e1 <argptr>
801059b4:	85 c0                	test   %eax,%eax
801059b6:	79 07                	jns    801059bf <sys_fstat+0x4b>
    return -1;
801059b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059bd:	eb 12                	jmp    801059d1 <sys_fstat+0x5d>
  return filestat(f, st);
801059bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059c5:	89 54 24 04          	mov    %edx,0x4(%esp)
801059c9:	89 04 24             	mov    %eax,(%esp)
801059cc:	e8 bf b6 ff ff       	call   80101090 <filestat>
}
801059d1:	c9                   	leave  
801059d2:	c3                   	ret    

801059d3 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059d3:	55                   	push   %ebp
801059d4:	89 e5                	mov    %esp,%ebp
801059d6:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059d9:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801059e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801059e7:	e8 57 fc ff ff       	call   80105643 <argstr>
801059ec:	85 c0                	test   %eax,%eax
801059ee:	78 17                	js     80105a07 <sys_link+0x34>
801059f0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801059f7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059fe:	e8 40 fc ff ff       	call   80105643 <argstr>
80105a03:	85 c0                	test   %eax,%eax
80105a05:	79 0a                	jns    80105a11 <sys_link+0x3e>
    return -1;
80105a07:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0c:	e9 3d 01 00 00       	jmp    80105b4e <sys_link+0x17b>
  if((ip = namei(old)) == 0)
80105a11:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a14:	89 04 24             	mov    %eax,(%esp)
80105a17:	e8 4a cb ff ff       	call   80102566 <namei>
80105a1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a1f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a23:	75 0a                	jne    80105a2f <sys_link+0x5c>
    return -1;
80105a25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2a:	e9 1f 01 00 00       	jmp    80105b4e <sys_link+0x17b>

  begin_trans();
80105a2f:	e8 11 d9 ff ff       	call   80103345 <begin_trans>

  ilock(ip);
80105a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a37:	89 04 24             	mov    %eax,(%esp)
80105a3a:	e8 08 be ff ff       	call   80101847 <ilock>
  if(ip->type == T_DIR){
80105a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a42:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a46:	66 83 f8 01          	cmp    $0x1,%ax
80105a4a:	75 1a                	jne    80105a66 <sys_link+0x93>
    iunlockput(ip);
80105a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4f:	89 04 24             	mov    %eax,(%esp)
80105a52:	e8 74 c0 ff ff       	call   80101acb <iunlockput>
    commit_trans();
80105a57:	e8 32 d9 ff ff       	call   8010338e <commit_trans>
    return -1;
80105a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a61:	e9 e8 00 00 00       	jmp    80105b4e <sys_link+0x17b>
  }

  ip->nlink++;
80105a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a69:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a6d:	8d 50 01             	lea    0x1(%eax),%edx
80105a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a73:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7a:	89 04 24             	mov    %eax,(%esp)
80105a7d:	e8 09 bc ff ff       	call   8010168b <iupdate>
  iunlock(ip);
80105a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a85:	89 04 24             	mov    %eax,(%esp)
80105a88:	e8 08 bf ff ff       	call   80101995 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105a8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a90:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a93:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a97:	89 04 24             	mov    %eax,(%esp)
80105a9a:	e8 e9 ca ff ff       	call   80102588 <nameiparent>
80105a9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105aa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105aa6:	75 02                	jne    80105aaa <sys_link+0xd7>
    goto bad;
80105aa8:	eb 68                	jmp    80105b12 <sys_link+0x13f>
  ilock(dp);
80105aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aad:	89 04 24             	mov    %eax,(%esp)
80105ab0:	e8 92 bd ff ff       	call   80101847 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ab8:	8b 10                	mov    (%eax),%edx
80105aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105abd:	8b 00                	mov    (%eax),%eax
80105abf:	39 c2                	cmp    %eax,%edx
80105ac1:	75 20                	jne    80105ae3 <sys_link+0x110>
80105ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac6:	8b 40 04             	mov    0x4(%eax),%eax
80105ac9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105acd:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad7:	89 04 24             	mov    %eax,(%esp)
80105ada:	e8 c7 c7 ff ff       	call   801022a6 <dirlink>
80105adf:	85 c0                	test   %eax,%eax
80105ae1:	79 0d                	jns    80105af0 <sys_link+0x11d>
    iunlockput(dp);
80105ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae6:	89 04 24             	mov    %eax,(%esp)
80105ae9:	e8 dd bf ff ff       	call   80101acb <iunlockput>
    goto bad;
80105aee:	eb 22                	jmp    80105b12 <sys_link+0x13f>
  }
  iunlockput(dp);
80105af0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af3:	89 04 24             	mov    %eax,(%esp)
80105af6:	e8 d0 bf ff ff       	call   80101acb <iunlockput>
  iput(ip);
80105afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afe:	89 04 24             	mov    %eax,(%esp)
80105b01:	e8 f4 be ff ff       	call   801019fa <iput>

  commit_trans();
80105b06:	e8 83 d8 ff ff       	call   8010338e <commit_trans>

  return 0;
80105b0b:	b8 00 00 00 00       	mov    $0x0,%eax
80105b10:	eb 3c                	jmp    80105b4e <sys_link+0x17b>

bad:
  ilock(ip);
80105b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b15:	89 04 24             	mov    %eax,(%esp)
80105b18:	e8 2a bd ff ff       	call   80101847 <ilock>
  ip->nlink--;
80105b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b20:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b24:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2a:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b31:	89 04 24             	mov    %eax,(%esp)
80105b34:	e8 52 bb ff ff       	call   8010168b <iupdate>
  iunlockput(ip);
80105b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3c:	89 04 24             	mov    %eax,(%esp)
80105b3f:	e8 87 bf ff ff       	call   80101acb <iunlockput>
  commit_trans();
80105b44:	e8 45 d8 ff ff       	call   8010338e <commit_trans>
  return -1;
80105b49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b4e:	c9                   	leave  
80105b4f:	c3                   	ret    

80105b50 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b50:	55                   	push   %ebp
80105b51:	89 e5                	mov    %esp,%ebp
80105b53:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b56:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b5d:	eb 4b                	jmp    80105baa <isdirempty+0x5a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b62:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105b69:	00 
80105b6a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105b6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b75:	8b 45 08             	mov    0x8(%ebp),%eax
80105b78:	89 04 24             	mov    %eax,(%esp)
80105b7b:	e8 48 c3 ff ff       	call   80101ec8 <readi>
80105b80:	83 f8 10             	cmp    $0x10,%eax
80105b83:	74 0c                	je     80105b91 <isdirempty+0x41>
      panic("isdirempty: readi");
80105b85:	c7 04 24 2f 8c 10 80 	movl   $0x80108c2f,(%esp)
80105b8c:	e8 a9 a9 ff ff       	call   8010053a <panic>
    if(de.inum != 0)
80105b91:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b95:	66 85 c0             	test   %ax,%ax
80105b98:	74 07                	je     80105ba1 <isdirempty+0x51>
      return 0;
80105b9a:	b8 00 00 00 00       	mov    $0x0,%eax
80105b9f:	eb 1b                	jmp    80105bbc <isdirempty+0x6c>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba4:	83 c0 10             	add    $0x10,%eax
80105ba7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105baa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bad:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb0:	8b 40 18             	mov    0x18(%eax),%eax
80105bb3:	39 c2                	cmp    %eax,%edx
80105bb5:	72 a8                	jb     80105b5f <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105bb7:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bbc:	c9                   	leave  
80105bbd:	c3                   	ret    

80105bbe <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105bbe:	55                   	push   %ebp
80105bbf:	89 e5                	mov    %esp,%ebp
80105bc1:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105bc4:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bcb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105bd2:	e8 6c fa ff ff       	call   80105643 <argstr>
80105bd7:	85 c0                	test   %eax,%eax
80105bd9:	79 0a                	jns    80105be5 <sys_unlink+0x27>
    return -1;
80105bdb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be0:	e9 aa 01 00 00       	jmp    80105d8f <sys_unlink+0x1d1>
  if((dp = nameiparent(path, name)) == 0)
80105be5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105be8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105beb:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bef:	89 04 24             	mov    %eax,(%esp)
80105bf2:	e8 91 c9 ff ff       	call   80102588 <nameiparent>
80105bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bfa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bfe:	75 0a                	jne    80105c0a <sys_unlink+0x4c>
    return -1;
80105c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c05:	e9 85 01 00 00       	jmp    80105d8f <sys_unlink+0x1d1>

  begin_trans();
80105c0a:	e8 36 d7 ff ff       	call   80103345 <begin_trans>

  ilock(dp);
80105c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c12:	89 04 24             	mov    %eax,(%esp)
80105c15:	e8 2d bc ff ff       	call   80101847 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c1a:	c7 44 24 04 41 8c 10 	movl   $0x80108c41,0x4(%esp)
80105c21:	80 
80105c22:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c25:	89 04 24             	mov    %eax,(%esp)
80105c28:	e8 8e c5 ff ff       	call   801021bb <namecmp>
80105c2d:	85 c0                	test   %eax,%eax
80105c2f:	0f 84 45 01 00 00    	je     80105d7a <sys_unlink+0x1bc>
80105c35:	c7 44 24 04 43 8c 10 	movl   $0x80108c43,0x4(%esp)
80105c3c:	80 
80105c3d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c40:	89 04 24             	mov    %eax,(%esp)
80105c43:	e8 73 c5 ff ff       	call   801021bb <namecmp>
80105c48:	85 c0                	test   %eax,%eax
80105c4a:	0f 84 2a 01 00 00    	je     80105d7a <sys_unlink+0x1bc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c50:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c53:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c57:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c61:	89 04 24             	mov    %eax,(%esp)
80105c64:	e8 74 c5 ff ff       	call   801021dd <dirlookup>
80105c69:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c6c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c70:	75 05                	jne    80105c77 <sys_unlink+0xb9>
    goto bad;
80105c72:	e9 03 01 00 00       	jmp    80105d7a <sys_unlink+0x1bc>
  ilock(ip);
80105c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7a:	89 04 24             	mov    %eax,(%esp)
80105c7d:	e8 c5 bb ff ff       	call   80101847 <ilock>

  if(ip->nlink < 1)
80105c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c85:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c89:	66 85 c0             	test   %ax,%ax
80105c8c:	7f 0c                	jg     80105c9a <sys_unlink+0xdc>
    panic("unlink: nlink < 1");
80105c8e:	c7 04 24 46 8c 10 80 	movl   $0x80108c46,(%esp)
80105c95:	e8 a0 a8 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ca1:	66 83 f8 01          	cmp    $0x1,%ax
80105ca5:	75 1f                	jne    80105cc6 <sys_unlink+0x108>
80105ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105caa:	89 04 24             	mov    %eax,(%esp)
80105cad:	e8 9e fe ff ff       	call   80105b50 <isdirempty>
80105cb2:	85 c0                	test   %eax,%eax
80105cb4:	75 10                	jne    80105cc6 <sys_unlink+0x108>
    iunlockput(ip);
80105cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cb9:	89 04 24             	mov    %eax,(%esp)
80105cbc:	e8 0a be ff ff       	call   80101acb <iunlockput>
    goto bad;
80105cc1:	e9 b4 00 00 00       	jmp    80105d7a <sys_unlink+0x1bc>
  }

  memset(&de, 0, sizeof(de));
80105cc6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105ccd:	00 
80105cce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cd5:	00 
80105cd6:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cd9:	89 04 24             	mov    %eax,(%esp)
80105cdc:	e8 90 f5 ff ff       	call   80105271 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ce1:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105ce4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105ceb:	00 
80105cec:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf0:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfa:	89 04 24             	mov    %eax,(%esp)
80105cfd:	e8 2a c3 ff ff       	call   8010202c <writei>
80105d02:	83 f8 10             	cmp    $0x10,%eax
80105d05:	74 0c                	je     80105d13 <sys_unlink+0x155>
    panic("unlink: writei");
80105d07:	c7 04 24 58 8c 10 80 	movl   $0x80108c58,(%esp)
80105d0e:	e8 27 a8 ff ff       	call   8010053a <panic>
  if(ip->type == T_DIR){
80105d13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d16:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d1a:	66 83 f8 01          	cmp    $0x1,%ax
80105d1e:	75 1c                	jne    80105d3c <sys_unlink+0x17e>
    dp->nlink--;
80105d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d23:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d27:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d34:	89 04 24             	mov    %eax,(%esp)
80105d37:	e8 4f b9 ff ff       	call   8010168b <iupdate>
  }
  iunlockput(dp);
80105d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3f:	89 04 24             	mov    %eax,(%esp)
80105d42:	e8 84 bd ff ff       	call   80101acb <iunlockput>

  ip->nlink--;
80105d47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d4a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d4e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d54:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5b:	89 04 24             	mov    %eax,(%esp)
80105d5e:	e8 28 b9 ff ff       	call   8010168b <iupdate>
  iunlockput(ip);
80105d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d66:	89 04 24             	mov    %eax,(%esp)
80105d69:	e8 5d bd ff ff       	call   80101acb <iunlockput>

  commit_trans();
80105d6e:	e8 1b d6 ff ff       	call   8010338e <commit_trans>

  return 0;
80105d73:	b8 00 00 00 00       	mov    $0x0,%eax
80105d78:	eb 15                	jmp    80105d8f <sys_unlink+0x1d1>

bad:
  iunlockput(dp);
80105d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7d:	89 04 24             	mov    %eax,(%esp)
80105d80:	e8 46 bd ff ff       	call   80101acb <iunlockput>
  commit_trans();
80105d85:	e8 04 d6 ff ff       	call   8010338e <commit_trans>
  return -1;
80105d8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d8f:	c9                   	leave  
80105d90:	c3                   	ret    

80105d91 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d91:	55                   	push   %ebp
80105d92:	89 e5                	mov    %esp,%ebp
80105d94:	83 ec 48             	sub    $0x48,%esp
80105d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d9a:	8b 55 10             	mov    0x10(%ebp),%edx
80105d9d:	8b 45 14             	mov    0x14(%ebp),%eax
80105da0:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105da4:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105da8:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105dac:	8d 45 de             	lea    -0x22(%ebp),%eax
80105daf:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db3:	8b 45 08             	mov    0x8(%ebp),%eax
80105db6:	89 04 24             	mov    %eax,(%esp)
80105db9:	e8 ca c7 ff ff       	call   80102588 <nameiparent>
80105dbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105dc1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dc5:	75 0a                	jne    80105dd1 <create+0x40>
    return 0;
80105dc7:	b8 00 00 00 00       	mov    $0x0,%eax
80105dcc:	e9 7e 01 00 00       	jmp    80105f4f <create+0x1be>
  ilock(dp);
80105dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dd4:	89 04 24             	mov    %eax,(%esp)
80105dd7:	e8 6b ba ff ff       	call   80101847 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105ddc:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ddf:	89 44 24 08          	mov    %eax,0x8(%esp)
80105de3:	8d 45 de             	lea    -0x22(%ebp),%eax
80105de6:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ded:	89 04 24             	mov    %eax,(%esp)
80105df0:	e8 e8 c3 ff ff       	call   801021dd <dirlookup>
80105df5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105df8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dfc:	74 47                	je     80105e45 <create+0xb4>
    iunlockput(dp);
80105dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e01:	89 04 24             	mov    %eax,(%esp)
80105e04:	e8 c2 bc ff ff       	call   80101acb <iunlockput>
    ilock(ip);
80105e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e0c:	89 04 24             	mov    %eax,(%esp)
80105e0f:	e8 33 ba ff ff       	call   80101847 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105e14:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e19:	75 15                	jne    80105e30 <create+0x9f>
80105e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e1e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e22:	66 83 f8 02          	cmp    $0x2,%ax
80105e26:	75 08                	jne    80105e30 <create+0x9f>
      return ip;
80105e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e2b:	e9 1f 01 00 00       	jmp    80105f4f <create+0x1be>
    iunlockput(ip);
80105e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e33:	89 04 24             	mov    %eax,(%esp)
80105e36:	e8 90 bc ff ff       	call   80101acb <iunlockput>
    return 0;
80105e3b:	b8 00 00 00 00       	mov    $0x0,%eax
80105e40:	e9 0a 01 00 00       	jmp    80105f4f <create+0x1be>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e45:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e4c:	8b 00                	mov    (%eax),%eax
80105e4e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e52:	89 04 24             	mov    %eax,(%esp)
80105e55:	e8 52 b7 ff ff       	call   801015ac <ialloc>
80105e5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e61:	75 0c                	jne    80105e6f <create+0xde>
    panic("create: ialloc");
80105e63:	c7 04 24 67 8c 10 80 	movl   $0x80108c67,(%esp)
80105e6a:	e8 cb a6 ff ff       	call   8010053a <panic>

  ilock(ip);
80105e6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e72:	89 04 24             	mov    %eax,(%esp)
80105e75:	e8 cd b9 ff ff       	call   80101847 <ilock>
  ip->major = major;
80105e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e81:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e88:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e8c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e93:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9c:	89 04 24             	mov    %eax,(%esp)
80105e9f:	e8 e7 b7 ff ff       	call   8010168b <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105ea4:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105ea9:	75 6a                	jne    80105f15 <create+0x184>
    dp->nlink++;  // for ".."
80105eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eae:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105eb2:	8d 50 01             	lea    0x1(%eax),%edx
80105eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb8:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebf:	89 04 24             	mov    %eax,(%esp)
80105ec2:	e8 c4 b7 ff ff       	call   8010168b <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eca:	8b 40 04             	mov    0x4(%eax),%eax
80105ecd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ed1:	c7 44 24 04 41 8c 10 	movl   $0x80108c41,0x4(%esp)
80105ed8:	80 
80105ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105edc:	89 04 24             	mov    %eax,(%esp)
80105edf:	e8 c2 c3 ff ff       	call   801022a6 <dirlink>
80105ee4:	85 c0                	test   %eax,%eax
80105ee6:	78 21                	js     80105f09 <create+0x178>
80105ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eeb:	8b 40 04             	mov    0x4(%eax),%eax
80105eee:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ef2:	c7 44 24 04 43 8c 10 	movl   $0x80108c43,0x4(%esp)
80105ef9:	80 
80105efa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efd:	89 04 24             	mov    %eax,(%esp)
80105f00:	e8 a1 c3 ff ff       	call   801022a6 <dirlink>
80105f05:	85 c0                	test   %eax,%eax
80105f07:	79 0c                	jns    80105f15 <create+0x184>
      panic("create dots");
80105f09:	c7 04 24 76 8c 10 80 	movl   $0x80108c76,(%esp)
80105f10:	e8 25 a6 ff ff       	call   8010053a <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f18:	8b 40 04             	mov    0x4(%eax),%eax
80105f1b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f1f:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f22:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f29:	89 04 24             	mov    %eax,(%esp)
80105f2c:	e8 75 c3 ff ff       	call   801022a6 <dirlink>
80105f31:	85 c0                	test   %eax,%eax
80105f33:	79 0c                	jns    80105f41 <create+0x1b0>
    panic("create: dirlink");
80105f35:	c7 04 24 82 8c 10 80 	movl   $0x80108c82,(%esp)
80105f3c:	e8 f9 a5 ff ff       	call   8010053a <panic>

  iunlockput(dp);
80105f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f44:	89 04 24             	mov    %eax,(%esp)
80105f47:	e8 7f bb ff ff       	call   80101acb <iunlockput>

  return ip;
80105f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f4f:	c9                   	leave  
80105f50:	c3                   	ret    

80105f51 <sys_open>:

int
sys_open(void)
{
80105f51:	55                   	push   %ebp
80105f52:	89 e5                	mov    %esp,%ebp
80105f54:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f57:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f65:	e8 d9 f6 ff ff       	call   80105643 <argstr>
80105f6a:	85 c0                	test   %eax,%eax
80105f6c:	78 17                	js     80105f85 <sys_open+0x34>
80105f6e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f71:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f75:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f7c:	e8 32 f6 ff ff       	call   801055b3 <argint>
80105f81:	85 c0                	test   %eax,%eax
80105f83:	79 0a                	jns    80105f8f <sys_open+0x3e>
    return -1;
80105f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8a:	e9 48 01 00 00       	jmp    801060d7 <sys_open+0x186>
  if(omode & O_CREATE){
80105f8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f92:	25 00 02 00 00       	and    $0x200,%eax
80105f97:	85 c0                	test   %eax,%eax
80105f99:	74 40                	je     80105fdb <sys_open+0x8a>
    begin_trans();
80105f9b:	e8 a5 d3 ff ff       	call   80103345 <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105fa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fa3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105faa:	00 
80105fab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105fb2:	00 
80105fb3:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105fba:	00 
80105fbb:	89 04 24             	mov    %eax,(%esp)
80105fbe:	e8 ce fd ff ff       	call   80105d91 <create>
80105fc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105fc6:	e8 c3 d3 ff ff       	call   8010338e <commit_trans>
    if(ip == 0)
80105fcb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fcf:	75 5c                	jne    8010602d <sys_open+0xdc>
      return -1;
80105fd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd6:	e9 fc 00 00 00       	jmp    801060d7 <sys_open+0x186>
  } else {
    if((ip = namei(path)) == 0)
80105fdb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fde:	89 04 24             	mov    %eax,(%esp)
80105fe1:	e8 80 c5 ff ff       	call   80102566 <namei>
80105fe6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fe9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fed:	75 0a                	jne    80105ff9 <sys_open+0xa8>
      return -1;
80105fef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ff4:	e9 de 00 00 00       	jmp    801060d7 <sys_open+0x186>
    ilock(ip);
80105ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffc:	89 04 24             	mov    %eax,(%esp)
80105fff:	e8 43 b8 ff ff       	call   80101847 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106004:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106007:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010600b:	66 83 f8 01          	cmp    $0x1,%ax
8010600f:	75 1c                	jne    8010602d <sys_open+0xdc>
80106011:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106014:	85 c0                	test   %eax,%eax
80106016:	74 15                	je     8010602d <sys_open+0xdc>
      iunlockput(ip);
80106018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601b:	89 04 24             	mov    %eax,(%esp)
8010601e:	e8 a8 ba ff ff       	call   80101acb <iunlockput>
      return -1;
80106023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106028:	e9 aa 00 00 00       	jmp    801060d7 <sys_open+0x186>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010602d:	e8 e0 ae ff ff       	call   80100f12 <filealloc>
80106032:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106035:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106039:	74 14                	je     8010604f <sys_open+0xfe>
8010603b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603e:	89 04 24             	mov    %eax,(%esp)
80106041:	e8 42 f7 ff ff       	call   80105788 <fdalloc>
80106046:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106049:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010604d:	79 23                	jns    80106072 <sys_open+0x121>
    if(f)
8010604f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106053:	74 0b                	je     80106060 <sys_open+0x10f>
      fileclose(f);
80106055:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106058:	89 04 24             	mov    %eax,(%esp)
8010605b:	e8 5a af ff ff       	call   80100fba <fileclose>
    iunlockput(ip);
80106060:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106063:	89 04 24             	mov    %eax,(%esp)
80106066:	e8 60 ba ff ff       	call   80101acb <iunlockput>
    return -1;
8010606b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106070:	eb 65                	jmp    801060d7 <sys_open+0x186>
  }
  iunlock(ip);
80106072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106075:	89 04 24             	mov    %eax,(%esp)
80106078:	e8 18 b9 ff ff       	call   80101995 <iunlock>

  f->type = FD_INODE;
8010607d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106080:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106086:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106089:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010608c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010608f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106092:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106099:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010609c:	83 e0 01             	and    $0x1,%eax
8010609f:	85 c0                	test   %eax,%eax
801060a1:	0f 94 c0             	sete   %al
801060a4:	89 c2                	mov    %eax,%edx
801060a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060af:	83 e0 01             	and    $0x1,%eax
801060b2:	85 c0                	test   %eax,%eax
801060b4:	75 0a                	jne    801060c0 <sys_open+0x16f>
801060b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b9:	83 e0 02             	and    $0x2,%eax
801060bc:	85 c0                	test   %eax,%eax
801060be:	74 07                	je     801060c7 <sys_open+0x176>
801060c0:	b8 01 00 00 00       	mov    $0x1,%eax
801060c5:	eb 05                	jmp    801060cc <sys_open+0x17b>
801060c7:	b8 00 00 00 00       	mov    $0x0,%eax
801060cc:	89 c2                	mov    %eax,%edx
801060ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d1:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060d7:	c9                   	leave  
801060d8:	c3                   	ret    

801060d9 <sys_mkdir>:

int
sys_mkdir(void)
{
801060d9:	55                   	push   %ebp
801060da:	89 e5                	mov    %esp,%ebp
801060dc:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
801060df:	e8 61 d2 ff ff       	call   80103345 <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801060e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801060eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060f2:	e8 4c f5 ff ff       	call   80105643 <argstr>
801060f7:	85 c0                	test   %eax,%eax
801060f9:	78 2c                	js     80106127 <sys_mkdir+0x4e>
801060fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106105:	00 
80106106:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010610d:	00 
8010610e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106115:	00 
80106116:	89 04 24             	mov    %eax,(%esp)
80106119:	e8 73 fc ff ff       	call   80105d91 <create>
8010611e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106121:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106125:	75 0c                	jne    80106133 <sys_mkdir+0x5a>
    commit_trans();
80106127:	e8 62 d2 ff ff       	call   8010338e <commit_trans>
    return -1;
8010612c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106131:	eb 15                	jmp    80106148 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106136:	89 04 24             	mov    %eax,(%esp)
80106139:	e8 8d b9 ff ff       	call   80101acb <iunlockput>
  commit_trans();
8010613e:	e8 4b d2 ff ff       	call   8010338e <commit_trans>
  return 0;
80106143:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106148:	c9                   	leave  
80106149:	c3                   	ret    

8010614a <sys_mknod>:

int
sys_mknod(void)
{
8010614a:	55                   	push   %ebp
8010614b:	89 e5                	mov    %esp,%ebp
8010614d:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80106150:	e8 f0 d1 ff ff       	call   80103345 <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80106155:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106158:	89 44 24 04          	mov    %eax,0x4(%esp)
8010615c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106163:	e8 db f4 ff ff       	call   80105643 <argstr>
80106168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010616b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010616f:	78 5e                	js     801061cf <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80106171:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106174:	89 44 24 04          	mov    %eax,0x4(%esp)
80106178:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010617f:	e8 2f f4 ff ff       	call   801055b3 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80106184:	85 c0                	test   %eax,%eax
80106186:	78 47                	js     801061cf <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106188:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010618b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010618f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106196:	e8 18 f4 ff ff       	call   801055b3 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010619b:	85 c0                	test   %eax,%eax
8010619d:	78 30                	js     801061cf <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010619f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a2:	0f bf c8             	movswl %ax,%ecx
801061a5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061a8:	0f bf d0             	movswl %ax,%edx
801061ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801061ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801061b2:	89 54 24 08          	mov    %edx,0x8(%esp)
801061b6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801061bd:	00 
801061be:	89 04 24             	mov    %eax,(%esp)
801061c1:	e8 cb fb ff ff       	call   80105d91 <create>
801061c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061cd:	75 0c                	jne    801061db <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
801061cf:	e8 ba d1 ff ff       	call   8010338e <commit_trans>
    return -1;
801061d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d9:	eb 15                	jmp    801061f0 <sys_mknod+0xa6>
  }
  iunlockput(ip);
801061db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061de:	89 04 24             	mov    %eax,(%esp)
801061e1:	e8 e5 b8 ff ff       	call   80101acb <iunlockput>
  commit_trans();
801061e6:	e8 a3 d1 ff ff       	call   8010338e <commit_trans>
  return 0;
801061eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061f0:	c9                   	leave  
801061f1:	c3                   	ret    

801061f2 <sys_chdir>:

int
sys_chdir(void)
{
801061f2:	55                   	push   %ebp
801061f3:	89 e5                	mov    %esp,%ebp
801061f5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
801061f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106206:	e8 38 f4 ff ff       	call   80105643 <argstr>
8010620b:	85 c0                	test   %eax,%eax
8010620d:	78 14                	js     80106223 <sys_chdir+0x31>
8010620f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106212:	89 04 24             	mov    %eax,(%esp)
80106215:	e8 4c c3 ff ff       	call   80102566 <namei>
8010621a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010621d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106221:	75 07                	jne    8010622a <sys_chdir+0x38>
    return -1;
80106223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106228:	eb 57                	jmp    80106281 <sys_chdir+0x8f>
  ilock(ip);
8010622a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622d:	89 04 24             	mov    %eax,(%esp)
80106230:	e8 12 b6 ff ff       	call   80101847 <ilock>
  if(ip->type != T_DIR){
80106235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106238:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010623c:	66 83 f8 01          	cmp    $0x1,%ax
80106240:	74 12                	je     80106254 <sys_chdir+0x62>
    iunlockput(ip);
80106242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106245:	89 04 24             	mov    %eax,(%esp)
80106248:	e8 7e b8 ff ff       	call   80101acb <iunlockput>
    return -1;
8010624d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106252:	eb 2d                	jmp    80106281 <sys_chdir+0x8f>
  }
  iunlock(ip);
80106254:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106257:	89 04 24             	mov    %eax,(%esp)
8010625a:	e8 36 b7 ff ff       	call   80101995 <iunlock>
  iput(proc->cwd);
8010625f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106265:	8b 40 68             	mov    0x68(%eax),%eax
80106268:	89 04 24             	mov    %eax,(%esp)
8010626b:	e8 8a b7 ff ff       	call   801019fa <iput>
  proc->cwd = ip;
80106270:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106276:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106279:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010627c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106281:	c9                   	leave  
80106282:	c3                   	ret    

80106283 <sys_exec>:

int
sys_exec(void)
{
80106283:	55                   	push   %ebp
80106284:	89 e5                	mov    %esp,%ebp
80106286:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010628c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010628f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106293:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010629a:	e8 a4 f3 ff ff       	call   80105643 <argstr>
8010629f:	85 c0                	test   %eax,%eax
801062a1:	78 1a                	js     801062bd <sys_exec+0x3a>
801062a3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801062ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062b4:	e8 fa f2 ff ff       	call   801055b3 <argint>
801062b9:	85 c0                	test   %eax,%eax
801062bb:	79 0a                	jns    801062c7 <sys_exec+0x44>
    return -1;
801062bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062c2:	e9 c8 00 00 00       	jmp    8010638f <sys_exec+0x10c>
  }
  memset(argv, 0, sizeof(argv));
801062c7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801062ce:	00 
801062cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801062d6:	00 
801062d7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062dd:	89 04 24             	mov    %eax,(%esp)
801062e0:	e8 8c ef ff ff       	call   80105271 <memset>
  for(i=0;; i++){
801062e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801062ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ef:	83 f8 1f             	cmp    $0x1f,%eax
801062f2:	76 0a                	jbe    801062fe <sys_exec+0x7b>
      return -1;
801062f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f9:	e9 91 00 00 00       	jmp    8010638f <sys_exec+0x10c>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801062fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106301:	c1 e0 02             	shl    $0x2,%eax
80106304:	89 c2                	mov    %eax,%edx
80106306:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010630c:	01 c2                	add    %eax,%edx
8010630e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106314:	89 44 24 04          	mov    %eax,0x4(%esp)
80106318:	89 14 24             	mov    %edx,(%esp)
8010631b:	e8 f7 f1 ff ff       	call   80105517 <fetchint>
80106320:	85 c0                	test   %eax,%eax
80106322:	79 07                	jns    8010632b <sys_exec+0xa8>
      return -1;
80106324:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106329:	eb 64                	jmp    8010638f <sys_exec+0x10c>
    if(uarg == 0){
8010632b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106331:	85 c0                	test   %eax,%eax
80106333:	75 26                	jne    8010635b <sys_exec+0xd8>
      argv[i] = 0;
80106335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106338:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010633f:	00 00 00 00 
      break;
80106343:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106344:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106347:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
8010634d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106351:	89 04 24             	mov    %eax,(%esp)
80106354:	e8 96 a7 ff ff       	call   80100aef <exec>
80106359:	eb 34                	jmp    8010638f <sys_exec+0x10c>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010635b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106361:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106364:	c1 e2 02             	shl    $0x2,%edx
80106367:	01 c2                	add    %eax,%edx
80106369:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010636f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106373:	89 04 24             	mov    %eax,(%esp)
80106376:	e8 d6 f1 ff ff       	call   80105551 <fetchstr>
8010637b:	85 c0                	test   %eax,%eax
8010637d:	79 07                	jns    80106386 <sys_exec+0x103>
      return -1;
8010637f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106384:	eb 09                	jmp    8010638f <sys_exec+0x10c>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106386:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010638a:	e9 5d ff ff ff       	jmp    801062ec <sys_exec+0x69>
  return exec(path, argv);
}
8010638f:	c9                   	leave  
80106390:	c3                   	ret    

80106391 <sys_pipe>:

int
sys_pipe(void)
{
80106391:	55                   	push   %ebp
80106392:	89 e5                	mov    %esp,%ebp
80106394:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106397:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010639e:	00 
8010639f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063ad:	e8 2f f2 ff ff       	call   801055e1 <argptr>
801063b2:	85 c0                	test   %eax,%eax
801063b4:	79 0a                	jns    801063c0 <sys_pipe+0x2f>
    return -1;
801063b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bb:	e9 9b 00 00 00       	jmp    8010645b <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
801063c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801063c7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063ca:	89 04 24             	mov    %eax,(%esp)
801063cd:	e8 5d d9 ff ff       	call   80103d2f <pipealloc>
801063d2:	85 c0                	test   %eax,%eax
801063d4:	79 07                	jns    801063dd <sys_pipe+0x4c>
    return -1;
801063d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063db:	eb 7e                	jmp    8010645b <sys_pipe+0xca>
  fd0 = -1;
801063dd:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801063e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063e7:	89 04 24             	mov    %eax,(%esp)
801063ea:	e8 99 f3 ff ff       	call   80105788 <fdalloc>
801063ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063f6:	78 14                	js     8010640c <sys_pipe+0x7b>
801063f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063fb:	89 04 24             	mov    %eax,(%esp)
801063fe:	e8 85 f3 ff ff       	call   80105788 <fdalloc>
80106403:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106406:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010640a:	79 37                	jns    80106443 <sys_pipe+0xb2>
    if(fd0 >= 0)
8010640c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106410:	78 14                	js     80106426 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80106412:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106418:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010641b:	83 c2 08             	add    $0x8,%edx
8010641e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106425:	00 
    fileclose(rf);
80106426:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106429:	89 04 24             	mov    %eax,(%esp)
8010642c:	e8 89 ab ff ff       	call   80100fba <fileclose>
    fileclose(wf);
80106431:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106434:	89 04 24             	mov    %eax,(%esp)
80106437:	e8 7e ab ff ff       	call   80100fba <fileclose>
    return -1;
8010643c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106441:	eb 18                	jmp    8010645b <sys_pipe+0xca>
  }
  fd[0] = fd0;
80106443:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106446:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106449:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010644b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010644e:	8d 50 04             	lea    0x4(%eax),%edx
80106451:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106454:	89 02                	mov    %eax,(%edx)
  return 0;
80106456:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010645b:	c9                   	leave  
8010645c:	c3                   	ret    

8010645d <sys_fork>:
extern int mtx_lock(int lock_id);
extern int mtx_unlock(int lock_id);

int
sys_fork(void)
{
8010645d:	55                   	push   %ebp
8010645e:	89 e5                	mov    %esp,%ebp
80106460:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106463:	e8 f8 df ff ff       	call   80104460 <fork>
}
80106468:	c9                   	leave  
80106469:	c3                   	ret    

8010646a <sys_exit>:

int
sys_exit(void)
{
8010646a:	55                   	push   %ebp
8010646b:	89 e5                	mov    %esp,%ebp
8010646d:	83 ec 08             	sub    $0x8,%esp
  exit();
80106470:	e8 4e e1 ff ff       	call   801045c3 <exit>
  return 0;  // not reached
80106475:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010647a:	c9                   	leave  
8010647b:	c3                   	ret    

8010647c <sys_wait>:

int
sys_wait(void)
{
8010647c:	55                   	push   %ebp
8010647d:	89 e5                	mov    %esp,%ebp
8010647f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106482:	e8 57 e2 ff ff       	call   801046de <wait>
}
80106487:	c9                   	leave  
80106488:	c3                   	ret    

80106489 <sys_kill>:

int
sys_kill(void)
{
80106489:	55                   	push   %ebp
8010648a:	89 e5                	mov    %esp,%ebp
8010648c:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010648f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106492:	89 44 24 04          	mov    %eax,0x4(%esp)
80106496:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010649d:	e8 11 f1 ff ff       	call   801055b3 <argint>
801064a2:	85 c0                	test   %eax,%eax
801064a4:	79 07                	jns    801064ad <sys_kill+0x24>
    return -1;
801064a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ab:	eb 0b                	jmp    801064b8 <sys_kill+0x2f>
  return kill(pid);
801064ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b0:	89 04 24             	mov    %eax,(%esp)
801064b3:	e8 ea e5 ff ff       	call   80104aa2 <kill>
}
801064b8:	c9                   	leave  
801064b9:	c3                   	ret    

801064ba <sys_getpid>:

int
sys_getpid(void)
{
801064ba:	55                   	push   %ebp
801064bb:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801064bd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064c3:	8b 40 10             	mov    0x10(%eax),%eax
}
801064c6:	5d                   	pop    %ebp
801064c7:	c3                   	ret    

801064c8 <sys_sbrk>:

int
sys_sbrk(void)
{
801064c8:	55                   	push   %ebp
801064c9:	89 e5                	mov    %esp,%ebp
801064cb:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801064ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801064d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064dc:	e8 d2 f0 ff ff       	call   801055b3 <argint>
801064e1:	85 c0                	test   %eax,%eax
801064e3:	79 07                	jns    801064ec <sys_sbrk+0x24>
    return -1;
801064e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ea:	eb 24                	jmp    80106510 <sys_sbrk+0x48>
  addr = proc->sz;
801064ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064f2:	8b 00                	mov    (%eax),%eax
801064f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801064f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064fa:	89 04 24             	mov    %eax,(%esp)
801064fd:	e8 b9 de ff ff       	call   801043bb <growproc>
80106502:	85 c0                	test   %eax,%eax
80106504:	79 07                	jns    8010650d <sys_sbrk+0x45>
    return -1;
80106506:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650b:	eb 03                	jmp    80106510 <sys_sbrk+0x48>
  return addr;
8010650d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106510:	c9                   	leave  
80106511:	c3                   	ret    

80106512 <sys_sleep>:

int
sys_sleep(void)
{
80106512:	55                   	push   %ebp
80106513:	89 e5                	mov    %esp,%ebp
80106515:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106518:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010651b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010651f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106526:	e8 88 f0 ff ff       	call   801055b3 <argint>
8010652b:	85 c0                	test   %eax,%eax
8010652d:	79 07                	jns    80106536 <sys_sleep+0x24>
    return -1;
8010652f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106534:	eb 6c                	jmp    801065a2 <sys_sleep+0x90>
  acquire(&tickslock);
80106536:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
8010653d:	e8 db ea ff ff       	call   8010501d <acquire>
  ticks0 = ticks;
80106542:	a1 e0 93 11 80       	mov    0x801193e0,%eax
80106547:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010654a:	eb 34                	jmp    80106580 <sys_sleep+0x6e>
    if(proc->killed){
8010654c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106552:	8b 40 24             	mov    0x24(%eax),%eax
80106555:	85 c0                	test   %eax,%eax
80106557:	74 13                	je     8010656c <sys_sleep+0x5a>
      release(&tickslock);
80106559:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
80106560:	e8 1a eb ff ff       	call   8010507f <release>
      return -1;
80106565:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010656a:	eb 36                	jmp    801065a2 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
8010656c:	c7 44 24 04 a0 8b 11 	movl   $0x80118ba0,0x4(%esp)
80106573:	80 
80106574:	c7 04 24 e0 93 11 80 	movl   $0x801193e0,(%esp)
8010657b:	e8 1b e4 ff ff       	call   8010499b <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106580:	a1 e0 93 11 80       	mov    0x801193e0,%eax
80106585:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106588:	89 c2                	mov    %eax,%edx
8010658a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658d:	39 c2                	cmp    %eax,%edx
8010658f:	72 bb                	jb     8010654c <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106591:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
80106598:	e8 e2 ea ff ff       	call   8010507f <release>
  return 0;
8010659d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065a2:	c9                   	leave  
801065a3:	c3                   	ret    

801065a4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065a4:	55                   	push   %ebp
801065a5:	89 e5                	mov    %esp,%ebp
801065a7:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801065aa:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
801065b1:	e8 67 ea ff ff       	call   8010501d <acquire>
  xticks = ticks;
801065b6:	a1 e0 93 11 80       	mov    0x801193e0,%eax
801065bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801065be:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
801065c5:	e8 b5 ea ff ff       	call   8010507f <release>
  return xticks;
801065ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065cd:	c9                   	leave  
801065ce:	c3                   	ret    

801065cf <sys_startBurst>:

int 
sys_startBurst(void){
801065cf:	55                   	push   %ebp
801065d0:	89 e5                	mov    %esp,%ebp
801065d2:	83 ec 18             	sub    $0x18,%esp
  
  uint xticks = sys_uptime();
801065d5:	e8 ca ff ff ff       	call   801065a4 <sys_uptime>
801065da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  proc->startTime = xticks;
801065dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065e6:	89 50 7c             	mov    %edx,0x7c(%eax)

  return xticks;
801065e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801065ec:	c9                   	leave  
801065ed:	c3                   	ret    

801065ee <sys_endBurst>:

int 
sys_endBurst(void){
801065ee:	55                   	push   %ebp
801065ef:	89 e5                	mov    %esp,%ebp
801065f1:	83 ec 18             	sub    $0x18,%esp

  uint endxticks;
  endxticks = sys_uptime()- proc->startTime;
801065f4:	e8 ab ff ff ff       	call   801065a4 <sys_uptime>
801065f9:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80106600:	8b 52 7c             	mov    0x7c(%edx),%edx
80106603:	29 d0                	sub    %edx,%eax
80106605:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(endxticks > 0 && proc->index <100){
80106608:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010660c:	74 43                	je     80106651 <sys_endBurst+0x63>
8010660e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106614:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010661a:	83 f8 63             	cmp    $0x63,%eax
8010661d:	7f 32                	jg     80106651 <sys_endBurst+0x63>
    proc->bursts[proc->index] = endxticks;
8010661f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106625:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010662c:	8b 8a 80 00 00 00    	mov    0x80(%edx),%ecx
80106632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106635:	83 c1 20             	add    $0x20,%ecx
80106638:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
    proc->index++;
8010663c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106642:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80106648:	83 c2 01             	add    $0x1,%edx
8010664b:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  }
  proc->arrIndex++;
80106651:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106657:	8b 90 1c 02 00 00    	mov    0x21c(%eax),%edx
8010665d:	83 c2 01             	add    $0x1,%edx
80106660:	89 90 1c 02 00 00    	mov    %edx,0x21c(%eax)
  return endxticks;
80106666:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106669:	c9                   	leave  
8010666a:	c3                   	ret    

8010666b <sys_print_bursts>:

int
sys_print_bursts(void){
8010666b:	55                   	push   %ebp
8010666c:	89 e5                	mov    %esp,%ebp
8010666e:	53                   	push   %ebx
8010666f:	83 ec 24             	sub    $0x24,%esp
 
  int i;
  proc->completeTime = sys_uptime();
80106672:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80106679:	e8 26 ff ff ff       	call   801065a4 <sys_uptime>
8010667e:	89 83 18 02 00 00    	mov    %eax,0x218(%ebx)


  for(i = 0; i < 16; i++){
80106684:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010668b:	eb 24                	jmp    801066b1 <sys_print_bursts+0x46>
      cprintf("%d ",proc->bursts[i]);
8010668d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106693:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106696:	83 c2 20             	add    $0x20,%edx
80106699:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010669d:	89 44 24 04          	mov    %eax,0x4(%esp)
801066a1:	c7 04 24 92 8c 10 80 	movl   $0x80108c92,(%esp)
801066a8:	e8 f3 9c ff ff       	call   801003a0 <cprintf>
 
  int i;
  proc->completeTime = sys_uptime();


  for(i = 0; i < 16; i++){
801066ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801066b1:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801066b5:	7e d6                	jle    8010668d <sys_print_bursts+0x22>
      cprintf("%d ",proc->bursts[i]);
  }
  cprintf("\n");
801066b7:	c7 04 24 96 8c 10 80 	movl   $0x80108c96,(%esp)
801066be:	e8 dd 9c ff ff       	call   801003a0 <cprintf>

  cprintf("turnaround time  %d ", proc->completeTime - proc->arrivalTime);
801066c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066c9:	8b 90 18 02 00 00    	mov    0x218(%eax),%edx
801066cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066d5:	8b 80 14 02 00 00    	mov    0x214(%eax),%eax
801066db:	29 c2                	sub    %eax,%edx
801066dd:	89 d0                	mov    %edx,%eax
801066df:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e3:	c7 04 24 98 8c 10 80 	movl   $0x80108c98,(%esp)
801066ea:	e8 b1 9c ff ff       	call   801003a0 <cprintf>
  cprintf("\n");
801066ef:	c7 04 24 96 8c 10 80 	movl   $0x80108c96,(%esp)
801066f6:	e8 a5 9c ff ff       	call   801003a0 <cprintf>

  // cprintf("completeTime   %d ", proc->completeTime);
  // cprintf("\n");


  return 0;
801066fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106700:	83 c4 24             	add    $0x24,%esp
80106703:	5b                   	pop    %ebx
80106704:	5d                   	pop    %ebp
80106705:	c3                   	ret    

80106706 <sys_thread_create>:

int
sys_thread_create(void)
{
80106706:	55                   	push   %ebp
80106707:	89 e5                	mov    %esp,%ebp
80106709:	83 ec 28             	sub    $0x28,%esp
   char *funct, *stack, *arg;
  //arg checking
  if(argptr(0, &funct, 1) < 0 || argptr(1, &stack, 0) || argptr(2, &arg, 0)) //XXX
8010670c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80106713:	00 
80106714:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106717:	89 44 24 04          	mov    %eax,0x4(%esp)
8010671b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106722:	e8 ba ee ff ff       	call   801055e1 <argptr>
80106727:	85 c0                	test   %eax,%eax
80106729:	78 3e                	js     80106769 <sys_thread_create+0x63>
8010672b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106732:	00 
80106733:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106736:	89 44 24 04          	mov    %eax,0x4(%esp)
8010673a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106741:	e8 9b ee ff ff       	call   801055e1 <argptr>
80106746:	85 c0                	test   %eax,%eax
80106748:	75 1f                	jne    80106769 <sys_thread_create+0x63>
8010674a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106751:	00 
80106752:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106755:	89 44 24 04          	mov    %eax,0x4(%esp)
80106759:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106760:	e8 7c ee ff ff       	call   801055e1 <argptr>
80106765:	85 c0                	test   %eax,%eax
80106767:	74 07                	je     80106770 <sys_thread_create+0x6a>
    return -1;
80106769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010676e:	eb 19                	jmp    80106789 <sys_thread_create+0x83>

  return thread_create((void*)funct, (void*)stack, (void*) arg);
80106770:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80106773:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106779:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010677d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106781:	89 04 24             	mov    %eax,(%esp)
80106784:	e8 8e e4 ff ff       	call   80104c17 <thread_create>

  //return thread_create((void*)function, (void*)stack, (void*) arg);
}
80106789:	c9                   	leave  
8010678a:	c3                   	ret    

8010678b <sys_thread_join>:

int 
sys_thread_join(void)
{
8010678b:	55                   	push   %ebp
8010678c:	89 e5                	mov    %esp,%ebp
8010678e:	83 ec 28             	sub    $0x28,%esp
  char* stacks;
  if(argptr(0, &stacks, 1) < 0)
80106791:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80106798:	00 
80106799:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010679c:	89 44 24 04          	mov    %eax,0x4(%esp)
801067a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067a7:	e8 35 ee ff ff       	call   801055e1 <argptr>
801067ac:	85 c0                	test   %eax,%eax
801067ae:	79 07                	jns    801067b7 <sys_thread_join+0x2c>
    return -1;
801067b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b5:	eb 0b                	jmp    801067c2 <sys_thread_join+0x37>
  return thread_join((void**)stacks);
801067b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ba:	89 04 24             	mov    %eax,(%esp)
801067bd:	e8 17 e6 ff ff       	call   80104dd9 <thread_join>
}
801067c2:	c9                   	leave  
801067c3:	c3                   	ret    

801067c4 <sys_mtx_create>:

int 
sys_mtx_create(void){
801067c4:	55                   	push   %ebp
801067c5:	89 e5                	mov    %esp,%ebp
801067c7:	83 ec 28             	sub    $0x28,%esp
   int locked;
   if(argint(0, &locked) < 0)
801067ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801067d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801067d8:	e8 d6 ed ff ff       	call   801055b3 <argint>
801067dd:	85 c0                	test   %eax,%eax
801067df:	79 07                	jns    801067e8 <sys_mtx_create+0x24>
     return -1;
801067e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067e6:	eb 0b                	jmp    801067f3 <sys_mtx_create+0x2f>
  return mtx_create(locked);
801067e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067eb:	89 04 24             	mov    %eax,(%esp)
801067ee:	e8 0e e7 ff ff       	call   80104f01 <mtx_create>

}
801067f3:	c9                   	leave  
801067f4:	c3                   	ret    

801067f5 <sys_mtx_lock>:
int
sys_mtx_lock(void)
{
801067f5:	55                   	push   %ebp
801067f6:	89 e5                	mov    %esp,%ebp
801067f8:	83 ec 28             	sub    $0x28,%esp
  int lock_id ;
  if(argint(0, &lock_id) < 0)
801067fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801067fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106802:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106809:	e8 a5 ed ff ff       	call   801055b3 <argint>
8010680e:	85 c0                	test   %eax,%eax
80106810:	79 07                	jns    80106819 <sys_mtx_lock+0x24>
    return -1;
80106812:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106817:	eb 0b                	jmp    80106824 <sys_mtx_lock+0x2f>
   return mtx_lock(lock_id);
80106819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681c:	89 04 24             	mov    %eax,(%esp)
8010681f:	e8 27 e7 ff ff       	call   80104f4b <mtx_lock>
}
80106824:	c9                   	leave  
80106825:	c3                   	ret    

80106826 <sys_mtx_unlock>:

int
sys_mtx_unlock(void)
{
80106826:	55                   	push   %ebp
80106827:	89 e5                	mov    %esp,%ebp
80106829:	83 ec 28             	sub    $0x28,%esp
  int lock_id;
  if(argint(0, &lock_id) < 0)
8010682c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010682f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106833:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010683a:	e8 74 ed ff ff       	call   801055b3 <argint>
8010683f:	85 c0                	test   %eax,%eax
80106841:	79 07                	jns    8010684a <sys_mtx_unlock+0x24>
    return -1;
80106843:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106848:	eb 0b                	jmp    80106855 <sys_mtx_unlock+0x2f>
  return mtx_unlock(lock_id);
8010684a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684d:	89 04 24             	mov    %eax,(%esp)
80106850:	e8 36 e7 ff ff       	call   80104f8b <mtx_unlock>
}
80106855:	c9                   	leave  
80106856:	c3                   	ret    

80106857 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106857:	55                   	push   %ebp
80106858:	89 e5                	mov    %esp,%ebp
8010685a:	83 ec 08             	sub    $0x8,%esp
8010685d:	8b 55 08             	mov    0x8(%ebp),%edx
80106860:	8b 45 0c             	mov    0xc(%ebp),%eax
80106863:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106867:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010686a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010686e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106872:	ee                   	out    %al,(%dx)
}
80106873:	c9                   	leave  
80106874:	c3                   	ret    

80106875 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106875:	55                   	push   %ebp
80106876:	89 e5                	mov    %esp,%ebp
80106878:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010687b:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
80106882:	00 
80106883:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
8010688a:	e8 c8 ff ff ff       	call   80106857 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010688f:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
80106896:	00 
80106897:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
8010689e:	e8 b4 ff ff ff       	call   80106857 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801068a3:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
801068aa:	00 
801068ab:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801068b2:	e8 a0 ff ff ff       	call   80106857 <outb>
  picenable(IRQ_TIMER);
801068b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068be:	e8 ff d2 ff ff       	call   80103bc2 <picenable>
}
801068c3:	c9                   	leave  
801068c4:	c3                   	ret    

801068c5 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801068c5:	1e                   	push   %ds
  pushl %es
801068c6:	06                   	push   %es
  pushl %fs
801068c7:	0f a0                	push   %fs
  pushl %gs
801068c9:	0f a8                	push   %gs
  pushal
801068cb:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
801068cc:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801068d0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801068d2:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
801068d4:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
801068d8:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
801068da:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
801068dc:	54                   	push   %esp
  call trap
801068dd:	e8 d8 01 00 00       	call   80106aba <trap>
  addl $4, %esp
801068e2:	83 c4 04             	add    $0x4,%esp

801068e5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801068e5:	61                   	popa   
  popl %gs
801068e6:	0f a9                	pop    %gs
  popl %fs
801068e8:	0f a1                	pop    %fs
  popl %es
801068ea:	07                   	pop    %es
  popl %ds
801068eb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801068ec:	83 c4 08             	add    $0x8,%esp
  iret
801068ef:	cf                   	iret   

801068f0 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801068f0:	55                   	push   %ebp
801068f1:	89 e5                	mov    %esp,%ebp
801068f3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801068f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801068f9:	83 e8 01             	sub    $0x1,%eax
801068fc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106900:	8b 45 08             	mov    0x8(%ebp),%eax
80106903:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106907:	8b 45 08             	mov    0x8(%ebp),%eax
8010690a:	c1 e8 10             	shr    $0x10,%eax
8010690d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106911:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106914:	0f 01 18             	lidtl  (%eax)
}
80106917:	c9                   	leave  
80106918:	c3                   	ret    

80106919 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106919:	55                   	push   %ebp
8010691a:	89 e5                	mov    %esp,%ebp
8010691c:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010691f:	0f 20 d0             	mov    %cr2,%eax
80106922:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106925:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106928:	c9                   	leave  
80106929:	c3                   	ret    

8010692a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010692a:	55                   	push   %ebp
8010692b:	89 e5                	mov    %esp,%ebp
8010692d:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106930:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106937:	e9 c3 00 00 00       	jmp    801069ff <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010693c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010693f:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
80106946:	89 c2                	mov    %eax,%edx
80106948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694b:	66 89 14 c5 e0 8b 11 	mov    %dx,-0x7fee7420(,%eax,8)
80106952:	80 
80106953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106956:	66 c7 04 c5 e2 8b 11 	movw   $0x8,-0x7fee741e(,%eax,8)
8010695d:	80 08 00 
80106960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106963:	0f b6 14 c5 e4 8b 11 	movzbl -0x7fee741c(,%eax,8),%edx
8010696a:	80 
8010696b:	83 e2 e0             	and    $0xffffffe0,%edx
8010696e:	88 14 c5 e4 8b 11 80 	mov    %dl,-0x7fee741c(,%eax,8)
80106975:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106978:	0f b6 14 c5 e4 8b 11 	movzbl -0x7fee741c(,%eax,8),%edx
8010697f:	80 
80106980:	83 e2 1f             	and    $0x1f,%edx
80106983:	88 14 c5 e4 8b 11 80 	mov    %dl,-0x7fee741c(,%eax,8)
8010698a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010698d:	0f b6 14 c5 e5 8b 11 	movzbl -0x7fee741b(,%eax,8),%edx
80106994:	80 
80106995:	83 e2 f0             	and    $0xfffffff0,%edx
80106998:	83 ca 0e             	or     $0xe,%edx
8010699b:	88 14 c5 e5 8b 11 80 	mov    %dl,-0x7fee741b(,%eax,8)
801069a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a5:	0f b6 14 c5 e5 8b 11 	movzbl -0x7fee741b(,%eax,8),%edx
801069ac:	80 
801069ad:	83 e2 ef             	and    $0xffffffef,%edx
801069b0:	88 14 c5 e5 8b 11 80 	mov    %dl,-0x7fee741b(,%eax,8)
801069b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ba:	0f b6 14 c5 e5 8b 11 	movzbl -0x7fee741b(,%eax,8),%edx
801069c1:	80 
801069c2:	83 e2 9f             	and    $0xffffff9f,%edx
801069c5:	88 14 c5 e5 8b 11 80 	mov    %dl,-0x7fee741b(,%eax,8)
801069cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069cf:	0f b6 14 c5 e5 8b 11 	movzbl -0x7fee741b(,%eax,8),%edx
801069d6:	80 
801069d7:	83 ca 80             	or     $0xffffff80,%edx
801069da:	88 14 c5 e5 8b 11 80 	mov    %dl,-0x7fee741b(,%eax,8)
801069e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e4:	8b 04 85 b8 b0 10 80 	mov    -0x7fef4f48(,%eax,4),%eax
801069eb:	c1 e8 10             	shr    $0x10,%eax
801069ee:	89 c2                	mov    %eax,%edx
801069f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f3:	66 89 14 c5 e6 8b 11 	mov    %dx,-0x7fee741a(,%eax,8)
801069fa:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801069fb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801069ff:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106a06:	0f 8e 30 ff ff ff    	jle    8010693c <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106a0c:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
80106a11:	66 a3 e0 8d 11 80    	mov    %ax,0x80118de0
80106a17:	66 c7 05 e2 8d 11 80 	movw   $0x8,0x80118de2
80106a1e:	08 00 
80106a20:	0f b6 05 e4 8d 11 80 	movzbl 0x80118de4,%eax
80106a27:	83 e0 e0             	and    $0xffffffe0,%eax
80106a2a:	a2 e4 8d 11 80       	mov    %al,0x80118de4
80106a2f:	0f b6 05 e4 8d 11 80 	movzbl 0x80118de4,%eax
80106a36:	83 e0 1f             	and    $0x1f,%eax
80106a39:	a2 e4 8d 11 80       	mov    %al,0x80118de4
80106a3e:	0f b6 05 e5 8d 11 80 	movzbl 0x80118de5,%eax
80106a45:	83 c8 0f             	or     $0xf,%eax
80106a48:	a2 e5 8d 11 80       	mov    %al,0x80118de5
80106a4d:	0f b6 05 e5 8d 11 80 	movzbl 0x80118de5,%eax
80106a54:	83 e0 ef             	and    $0xffffffef,%eax
80106a57:	a2 e5 8d 11 80       	mov    %al,0x80118de5
80106a5c:	0f b6 05 e5 8d 11 80 	movzbl 0x80118de5,%eax
80106a63:	83 c8 60             	or     $0x60,%eax
80106a66:	a2 e5 8d 11 80       	mov    %al,0x80118de5
80106a6b:	0f b6 05 e5 8d 11 80 	movzbl 0x80118de5,%eax
80106a72:	83 c8 80             	or     $0xffffff80,%eax
80106a75:	a2 e5 8d 11 80       	mov    %al,0x80118de5
80106a7a:	a1 b8 b1 10 80       	mov    0x8010b1b8,%eax
80106a7f:	c1 e8 10             	shr    $0x10,%eax
80106a82:	66 a3 e6 8d 11 80    	mov    %ax,0x80118de6
  
  initlock(&tickslock, "time");
80106a88:	c7 44 24 04 b0 8c 10 	movl   $0x80108cb0,0x4(%esp)
80106a8f:	80 
80106a90:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
80106a97:	e8 60 e5 ff ff       	call   80104ffc <initlock>
}
80106a9c:	c9                   	leave  
80106a9d:	c3                   	ret    

80106a9e <idtinit>:

void
idtinit(void)
{
80106a9e:	55                   	push   %ebp
80106a9f:	89 e5                	mov    %esp,%ebp
80106aa1:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106aa4:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106aab:	00 
80106aac:	c7 04 24 e0 8b 11 80 	movl   $0x80118be0,(%esp)
80106ab3:	e8 38 fe ff ff       	call   801068f0 <lidt>
}
80106ab8:	c9                   	leave  
80106ab9:	c3                   	ret    

80106aba <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106aba:	55                   	push   %ebp
80106abb:	89 e5                	mov    %esp,%ebp
80106abd:	57                   	push   %edi
80106abe:	56                   	push   %esi
80106abf:	53                   	push   %ebx
80106ac0:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
80106ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ac6:	8b 40 30             	mov    0x30(%eax),%eax
80106ac9:	83 f8 40             	cmp    $0x40,%eax
80106acc:	75 3f                	jne    80106b0d <trap+0x53>
    if(proc->killed)
80106ace:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ad4:	8b 40 24             	mov    0x24(%eax),%eax
80106ad7:	85 c0                	test   %eax,%eax
80106ad9:	74 05                	je     80106ae0 <trap+0x26>
      exit();
80106adb:	e8 e3 da ff ff       	call   801045c3 <exit>
    proc->tf = tf;
80106ae0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ae6:	8b 55 08             	mov    0x8(%ebp),%edx
80106ae9:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106aec:	e8 89 eb ff ff       	call   8010567a <syscall>
    if(proc->killed)
80106af1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106af7:	8b 40 24             	mov    0x24(%eax),%eax
80106afa:	85 c0                	test   %eax,%eax
80106afc:	74 0a                	je     80106b08 <trap+0x4e>
      exit();
80106afe:	e8 c0 da ff ff       	call   801045c3 <exit>
    return;
80106b03:	e9 2d 02 00 00       	jmp    80106d35 <trap+0x27b>
80106b08:	e9 28 02 00 00       	jmp    80106d35 <trap+0x27b>
  }

  switch(tf->trapno){
80106b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80106b10:	8b 40 30             	mov    0x30(%eax),%eax
80106b13:	83 e8 20             	sub    $0x20,%eax
80106b16:	83 f8 1f             	cmp    $0x1f,%eax
80106b19:	0f 87 bc 00 00 00    	ja     80106bdb <trap+0x121>
80106b1f:	8b 04 85 58 8d 10 80 	mov    -0x7fef72a8(,%eax,4),%eax
80106b26:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106b28:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b2e:	0f b6 00             	movzbl (%eax),%eax
80106b31:	84 c0                	test   %al,%al
80106b33:	75 31                	jne    80106b66 <trap+0xac>
      acquire(&tickslock);
80106b35:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
80106b3c:	e8 dc e4 ff ff       	call   8010501d <acquire>
      ticks++;
80106b41:	a1 e0 93 11 80       	mov    0x801193e0,%eax
80106b46:	83 c0 01             	add    $0x1,%eax
80106b49:	a3 e0 93 11 80       	mov    %eax,0x801193e0
      wakeup(&ticks);
80106b4e:	c7 04 24 e0 93 11 80 	movl   $0x801193e0,(%esp)
80106b55:	e8 1d df ff ff       	call   80104a77 <wakeup>
      release(&tickslock);
80106b5a:	c7 04 24 a0 8b 11 80 	movl   $0x80118ba0,(%esp)
80106b61:	e8 19 e5 ff ff       	call   8010507f <release>
    }
    lapiceoi();
80106b66:	e8 a8 c4 ff ff       	call   80103013 <lapiceoi>
    break;
80106b6b:	e9 41 01 00 00       	jmp    80106cb1 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b70:	e8 c9 bc ff ff       	call   8010283e <ideintr>
    lapiceoi();
80106b75:	e8 99 c4 ff ff       	call   80103013 <lapiceoi>
    break;
80106b7a:	e9 32 01 00 00       	jmp    80106cb1 <trap+0x1f7>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b7f:	e8 7b c2 ff ff       	call   80102dff <kbdintr>
    lapiceoi();
80106b84:	e8 8a c4 ff ff       	call   80103013 <lapiceoi>
    break;
80106b89:	e9 23 01 00 00       	jmp    80106cb1 <trap+0x1f7>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b8e:	e8 97 03 00 00       	call   80106f2a <uartintr>
    lapiceoi();
80106b93:	e8 7b c4 ff ff       	call   80103013 <lapiceoi>
    break;
80106b98:	e9 14 01 00 00       	jmp    80106cb1 <trap+0x1f7>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba0:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80106ba6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106baa:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106bad:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bb3:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106bb6:	0f b6 c0             	movzbl %al,%eax
80106bb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106bbd:	89 54 24 08          	mov    %edx,0x8(%esp)
80106bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bc5:	c7 04 24 b8 8c 10 80 	movl   $0x80108cb8,(%esp)
80106bcc:	e8 cf 97 ff ff       	call   801003a0 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106bd1:	e8 3d c4 ff ff       	call   80103013 <lapiceoi>
    break;
80106bd6:	e9 d6 00 00 00       	jmp    80106cb1 <trap+0x1f7>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106bdb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106be1:	85 c0                	test   %eax,%eax
80106be3:	74 11                	je     80106bf6 <trap+0x13c>
80106be5:	8b 45 08             	mov    0x8(%ebp),%eax
80106be8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106bec:	0f b7 c0             	movzwl %ax,%eax
80106bef:	83 e0 03             	and    $0x3,%eax
80106bf2:	85 c0                	test   %eax,%eax
80106bf4:	75 46                	jne    80106c3c <trap+0x182>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106bf6:	e8 1e fd ff ff       	call   80106919 <rcr2>
80106bfb:	8b 55 08             	mov    0x8(%ebp),%edx
80106bfe:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106c01:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106c08:	0f b6 12             	movzbl (%edx),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106c0b:	0f b6 ca             	movzbl %dl,%ecx
80106c0e:	8b 55 08             	mov    0x8(%ebp),%edx
80106c11:	8b 52 30             	mov    0x30(%edx),%edx
80106c14:	89 44 24 10          	mov    %eax,0x10(%esp)
80106c18:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80106c1c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106c20:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c24:	c7 04 24 dc 8c 10 80 	movl   $0x80108cdc,(%esp)
80106c2b:	e8 70 97 ff ff       	call   801003a0 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106c30:	c7 04 24 0e 8d 10 80 	movl   $0x80108d0e,(%esp)
80106c37:	e8 fe 98 ff ff       	call   8010053a <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c3c:	e8 d8 fc ff ff       	call   80106919 <rcr2>
80106c41:	89 c2                	mov    %eax,%edx
80106c43:	8b 45 08             	mov    0x8(%ebp),%eax
80106c46:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c49:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106c4f:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c52:	0f b6 f0             	movzbl %al,%esi
80106c55:	8b 45 08             	mov    0x8(%ebp),%eax
80106c58:	8b 58 34             	mov    0x34(%eax),%ebx
80106c5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5e:	8b 48 30             	mov    0x30(%eax),%ecx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c67:	83 c0 6c             	add    $0x6c,%eax
80106c6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106c6d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c73:	8b 40 10             	mov    0x10(%eax),%eax
80106c76:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106c7a:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106c7e:	89 74 24 14          	mov    %esi,0x14(%esp)
80106c82:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106c86:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c8a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80106c8d:	89 74 24 08          	mov    %esi,0x8(%esp)
80106c91:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c95:	c7 04 24 14 8d 10 80 	movl   $0x80108d14,(%esp)
80106c9c:	e8 ff 96 ff ff       	call   801003a0 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106ca1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106cae:	eb 01                	jmp    80106cb1 <trap+0x1f7>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106cb0:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106cb1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cb7:	85 c0                	test   %eax,%eax
80106cb9:	74 24                	je     80106cdf <trap+0x225>
80106cbb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cc1:	8b 40 24             	mov    0x24(%eax),%eax
80106cc4:	85 c0                	test   %eax,%eax
80106cc6:	74 17                	je     80106cdf <trap+0x225>
80106cc8:	8b 45 08             	mov    0x8(%ebp),%eax
80106ccb:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ccf:	0f b7 c0             	movzwl %ax,%eax
80106cd2:	83 e0 03             	and    $0x3,%eax
80106cd5:	83 f8 03             	cmp    $0x3,%eax
80106cd8:	75 05                	jne    80106cdf <trap+0x225>
    exit();
80106cda:	e8 e4 d8 ff ff       	call   801045c3 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106cdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ce5:	85 c0                	test   %eax,%eax
80106ce7:	74 1e                	je     80106d07 <trap+0x24d>
80106ce9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106cef:	8b 40 0c             	mov    0xc(%eax),%eax
80106cf2:	83 f8 04             	cmp    $0x4,%eax
80106cf5:	75 10                	jne    80106d07 <trap+0x24d>
80106cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80106cfa:	8b 40 30             	mov    0x30(%eax),%eax
80106cfd:	83 f8 20             	cmp    $0x20,%eax
80106d00:	75 05                	jne    80106d07 <trap+0x24d>
    yield();
80106d02:	e8 36 dc ff ff       	call   8010493d <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106d07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d0d:	85 c0                	test   %eax,%eax
80106d0f:	74 24                	je     80106d35 <trap+0x27b>
80106d11:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d17:	8b 40 24             	mov    0x24(%eax),%eax
80106d1a:	85 c0                	test   %eax,%eax
80106d1c:	74 17                	je     80106d35 <trap+0x27b>
80106d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d21:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106d25:	0f b7 c0             	movzwl %ax,%eax
80106d28:	83 e0 03             	and    $0x3,%eax
80106d2b:	83 f8 03             	cmp    $0x3,%eax
80106d2e:	75 05                	jne    80106d35 <trap+0x27b>
    exit();
80106d30:	e8 8e d8 ff ff       	call   801045c3 <exit>
}
80106d35:	83 c4 3c             	add    $0x3c,%esp
80106d38:	5b                   	pop    %ebx
80106d39:	5e                   	pop    %esi
80106d3a:	5f                   	pop    %edi
80106d3b:	5d                   	pop    %ebp
80106d3c:	c3                   	ret    

80106d3d <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106d3d:	55                   	push   %ebp
80106d3e:	89 e5                	mov    %esp,%ebp
80106d40:	83 ec 14             	sub    $0x14,%esp
80106d43:	8b 45 08             	mov    0x8(%ebp),%eax
80106d46:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106d4a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106d4e:	89 c2                	mov    %eax,%edx
80106d50:	ec                   	in     (%dx),%al
80106d51:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106d54:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106d58:	c9                   	leave  
80106d59:	c3                   	ret    

80106d5a <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106d5a:	55                   	push   %ebp
80106d5b:	89 e5                	mov    %esp,%ebp
80106d5d:	83 ec 08             	sub    $0x8,%esp
80106d60:	8b 55 08             	mov    0x8(%ebp),%edx
80106d63:	8b 45 0c             	mov    0xc(%ebp),%eax
80106d66:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106d6a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d6d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d71:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d75:	ee                   	out    %al,(%dx)
}
80106d76:	c9                   	leave  
80106d77:	c3                   	ret    

80106d78 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d78:	55                   	push   %ebp
80106d79:	89 e5                	mov    %esp,%ebp
80106d7b:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106d85:	00 
80106d86:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106d8d:	e8 c8 ff ff ff       	call   80106d5a <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d92:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106d99:	00 
80106d9a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106da1:	e8 b4 ff ff ff       	call   80106d5a <outb>
  outb(COM1+0, 115200/9600);
80106da6:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106dad:	00 
80106dae:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106db5:	e8 a0 ff ff ff       	call   80106d5a <outb>
  outb(COM1+1, 0);
80106dba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106dc1:	00 
80106dc2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106dc9:	e8 8c ff ff ff       	call   80106d5a <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106dce:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106dd5:	00 
80106dd6:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106ddd:	e8 78 ff ff ff       	call   80106d5a <outb>
  outb(COM1+4, 0);
80106de2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106de9:	00 
80106dea:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106df1:	e8 64 ff ff ff       	call   80106d5a <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106df6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106dfd:	00 
80106dfe:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e05:	e8 50 ff ff ff       	call   80106d5a <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106e0a:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106e11:	e8 27 ff ff ff       	call   80106d3d <inb>
80106e16:	3c ff                	cmp    $0xff,%al
80106e18:	75 02                	jne    80106e1c <uartinit+0xa4>
    return;
80106e1a:	eb 6a                	jmp    80106e86 <uartinit+0x10e>
  uart = 1;
80106e1c:	c7 05 70 b6 10 80 01 	movl   $0x1,0x8010b670
80106e23:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106e26:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e2d:	e8 0b ff ff ff       	call   80106d3d <inb>
  inb(COM1+0);
80106e32:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e39:	e8 ff fe ff ff       	call   80106d3d <inb>
  picenable(IRQ_COM1);
80106e3e:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e45:	e8 78 cd ff ff       	call   80103bc2 <picenable>
  ioapicenable(IRQ_COM1, 0);
80106e4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e51:	00 
80106e52:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e59:	e8 5f bc ff ff       	call   80102abd <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e5e:	c7 45 f4 d8 8d 10 80 	movl   $0x80108dd8,-0xc(%ebp)
80106e65:	eb 15                	jmp    80106e7c <uartinit+0x104>
    uartputc(*p);
80106e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e6a:	0f b6 00             	movzbl (%eax),%eax
80106e6d:	0f be c0             	movsbl %al,%eax
80106e70:	89 04 24             	mov    %eax,(%esp)
80106e73:	e8 10 00 00 00       	call   80106e88 <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106e78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7f:	0f b6 00             	movzbl (%eax),%eax
80106e82:	84 c0                	test   %al,%al
80106e84:	75 e1                	jne    80106e67 <uartinit+0xef>
    uartputc(*p);
}
80106e86:	c9                   	leave  
80106e87:	c3                   	ret    

80106e88 <uartputc>:

void
uartputc(int c)
{
80106e88:	55                   	push   %ebp
80106e89:	89 e5                	mov    %esp,%ebp
80106e8b:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106e8e:	a1 70 b6 10 80       	mov    0x8010b670,%eax
80106e93:	85 c0                	test   %eax,%eax
80106e95:	75 02                	jne    80106e99 <uartputc+0x11>
    return;
80106e97:	eb 4b                	jmp    80106ee4 <uartputc+0x5c>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ea0:	eb 10                	jmp    80106eb2 <uartputc+0x2a>
    microdelay(10);
80106ea2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106ea9:	e8 8a c1 ff ff       	call   80103038 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106eae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106eb2:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106eb6:	7f 16                	jg     80106ece <uartputc+0x46>
80106eb8:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106ebf:	e8 79 fe ff ff       	call   80106d3d <inb>
80106ec4:	0f b6 c0             	movzbl %al,%eax
80106ec7:	83 e0 20             	and    $0x20,%eax
80106eca:	85 c0                	test   %eax,%eax
80106ecc:	74 d4                	je     80106ea2 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106ece:	8b 45 08             	mov    0x8(%ebp),%eax
80106ed1:	0f b6 c0             	movzbl %al,%eax
80106ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ed8:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106edf:	e8 76 fe ff ff       	call   80106d5a <outb>
}
80106ee4:	c9                   	leave  
80106ee5:	c3                   	ret    

80106ee6 <uartgetc>:

static int
uartgetc(void)
{
80106ee6:	55                   	push   %ebp
80106ee7:	89 e5                	mov    %esp,%ebp
80106ee9:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106eec:	a1 70 b6 10 80       	mov    0x8010b670,%eax
80106ef1:	85 c0                	test   %eax,%eax
80106ef3:	75 07                	jne    80106efc <uartgetc+0x16>
    return -1;
80106ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106efa:	eb 2c                	jmp    80106f28 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106efc:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f03:	e8 35 fe ff ff       	call   80106d3d <inb>
80106f08:	0f b6 c0             	movzbl %al,%eax
80106f0b:	83 e0 01             	and    $0x1,%eax
80106f0e:	85 c0                	test   %eax,%eax
80106f10:	75 07                	jne    80106f19 <uartgetc+0x33>
    return -1;
80106f12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f17:	eb 0f                	jmp    80106f28 <uartgetc+0x42>
  return inb(COM1+0);
80106f19:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f20:	e8 18 fe ff ff       	call   80106d3d <inb>
80106f25:	0f b6 c0             	movzbl %al,%eax
}
80106f28:	c9                   	leave  
80106f29:	c3                   	ret    

80106f2a <uartintr>:

void
uartintr(void)
{
80106f2a:	55                   	push   %ebp
80106f2b:	89 e5                	mov    %esp,%ebp
80106f2d:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106f30:	c7 04 24 e6 6e 10 80 	movl   $0x80106ee6,(%esp)
80106f37:	e8 71 98 ff ff       	call   801007ad <consoleintr>
}
80106f3c:	c9                   	leave  
80106f3d:	c3                   	ret    

80106f3e <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $0
80106f40:	6a 00                	push   $0x0
  jmp alltraps
80106f42:	e9 7e f9 ff ff       	jmp    801068c5 <alltraps>

80106f47 <vector1>:
.globl vector1
vector1:
  pushl $0
80106f47:	6a 00                	push   $0x0
  pushl $1
80106f49:	6a 01                	push   $0x1
  jmp alltraps
80106f4b:	e9 75 f9 ff ff       	jmp    801068c5 <alltraps>

80106f50 <vector2>:
.globl vector2
vector2:
  pushl $0
80106f50:	6a 00                	push   $0x0
  pushl $2
80106f52:	6a 02                	push   $0x2
  jmp alltraps
80106f54:	e9 6c f9 ff ff       	jmp    801068c5 <alltraps>

80106f59 <vector3>:
.globl vector3
vector3:
  pushl $0
80106f59:	6a 00                	push   $0x0
  pushl $3
80106f5b:	6a 03                	push   $0x3
  jmp alltraps
80106f5d:	e9 63 f9 ff ff       	jmp    801068c5 <alltraps>

80106f62 <vector4>:
.globl vector4
vector4:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $4
80106f64:	6a 04                	push   $0x4
  jmp alltraps
80106f66:	e9 5a f9 ff ff       	jmp    801068c5 <alltraps>

80106f6b <vector5>:
.globl vector5
vector5:
  pushl $0
80106f6b:	6a 00                	push   $0x0
  pushl $5
80106f6d:	6a 05                	push   $0x5
  jmp alltraps
80106f6f:	e9 51 f9 ff ff       	jmp    801068c5 <alltraps>

80106f74 <vector6>:
.globl vector6
vector6:
  pushl $0
80106f74:	6a 00                	push   $0x0
  pushl $6
80106f76:	6a 06                	push   $0x6
  jmp alltraps
80106f78:	e9 48 f9 ff ff       	jmp    801068c5 <alltraps>

80106f7d <vector7>:
.globl vector7
vector7:
  pushl $0
80106f7d:	6a 00                	push   $0x0
  pushl $7
80106f7f:	6a 07                	push   $0x7
  jmp alltraps
80106f81:	e9 3f f9 ff ff       	jmp    801068c5 <alltraps>

80106f86 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f86:	6a 08                	push   $0x8
  jmp alltraps
80106f88:	e9 38 f9 ff ff       	jmp    801068c5 <alltraps>

80106f8d <vector9>:
.globl vector9
vector9:
  pushl $0
80106f8d:	6a 00                	push   $0x0
  pushl $9
80106f8f:	6a 09                	push   $0x9
  jmp alltraps
80106f91:	e9 2f f9 ff ff       	jmp    801068c5 <alltraps>

80106f96 <vector10>:
.globl vector10
vector10:
  pushl $10
80106f96:	6a 0a                	push   $0xa
  jmp alltraps
80106f98:	e9 28 f9 ff ff       	jmp    801068c5 <alltraps>

80106f9d <vector11>:
.globl vector11
vector11:
  pushl $11
80106f9d:	6a 0b                	push   $0xb
  jmp alltraps
80106f9f:	e9 21 f9 ff ff       	jmp    801068c5 <alltraps>

80106fa4 <vector12>:
.globl vector12
vector12:
  pushl $12
80106fa4:	6a 0c                	push   $0xc
  jmp alltraps
80106fa6:	e9 1a f9 ff ff       	jmp    801068c5 <alltraps>

80106fab <vector13>:
.globl vector13
vector13:
  pushl $13
80106fab:	6a 0d                	push   $0xd
  jmp alltraps
80106fad:	e9 13 f9 ff ff       	jmp    801068c5 <alltraps>

80106fb2 <vector14>:
.globl vector14
vector14:
  pushl $14
80106fb2:	6a 0e                	push   $0xe
  jmp alltraps
80106fb4:	e9 0c f9 ff ff       	jmp    801068c5 <alltraps>

80106fb9 <vector15>:
.globl vector15
vector15:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $15
80106fbb:	6a 0f                	push   $0xf
  jmp alltraps
80106fbd:	e9 03 f9 ff ff       	jmp    801068c5 <alltraps>

80106fc2 <vector16>:
.globl vector16
vector16:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $16
80106fc4:	6a 10                	push   $0x10
  jmp alltraps
80106fc6:	e9 fa f8 ff ff       	jmp    801068c5 <alltraps>

80106fcb <vector17>:
.globl vector17
vector17:
  pushl $17
80106fcb:	6a 11                	push   $0x11
  jmp alltraps
80106fcd:	e9 f3 f8 ff ff       	jmp    801068c5 <alltraps>

80106fd2 <vector18>:
.globl vector18
vector18:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $18
80106fd4:	6a 12                	push   $0x12
  jmp alltraps
80106fd6:	e9 ea f8 ff ff       	jmp    801068c5 <alltraps>

80106fdb <vector19>:
.globl vector19
vector19:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $19
80106fdd:	6a 13                	push   $0x13
  jmp alltraps
80106fdf:	e9 e1 f8 ff ff       	jmp    801068c5 <alltraps>

80106fe4 <vector20>:
.globl vector20
vector20:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $20
80106fe6:	6a 14                	push   $0x14
  jmp alltraps
80106fe8:	e9 d8 f8 ff ff       	jmp    801068c5 <alltraps>

80106fed <vector21>:
.globl vector21
vector21:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $21
80106fef:	6a 15                	push   $0x15
  jmp alltraps
80106ff1:	e9 cf f8 ff ff       	jmp    801068c5 <alltraps>

80106ff6 <vector22>:
.globl vector22
vector22:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $22
80106ff8:	6a 16                	push   $0x16
  jmp alltraps
80106ffa:	e9 c6 f8 ff ff       	jmp    801068c5 <alltraps>

80106fff <vector23>:
.globl vector23
vector23:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $23
80107001:	6a 17                	push   $0x17
  jmp alltraps
80107003:	e9 bd f8 ff ff       	jmp    801068c5 <alltraps>

80107008 <vector24>:
.globl vector24
vector24:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $24
8010700a:	6a 18                	push   $0x18
  jmp alltraps
8010700c:	e9 b4 f8 ff ff       	jmp    801068c5 <alltraps>

80107011 <vector25>:
.globl vector25
vector25:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $25
80107013:	6a 19                	push   $0x19
  jmp alltraps
80107015:	e9 ab f8 ff ff       	jmp    801068c5 <alltraps>

8010701a <vector26>:
.globl vector26
vector26:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $26
8010701c:	6a 1a                	push   $0x1a
  jmp alltraps
8010701e:	e9 a2 f8 ff ff       	jmp    801068c5 <alltraps>

80107023 <vector27>:
.globl vector27
vector27:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $27
80107025:	6a 1b                	push   $0x1b
  jmp alltraps
80107027:	e9 99 f8 ff ff       	jmp    801068c5 <alltraps>

8010702c <vector28>:
.globl vector28
vector28:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $28
8010702e:	6a 1c                	push   $0x1c
  jmp alltraps
80107030:	e9 90 f8 ff ff       	jmp    801068c5 <alltraps>

80107035 <vector29>:
.globl vector29
vector29:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $29
80107037:	6a 1d                	push   $0x1d
  jmp alltraps
80107039:	e9 87 f8 ff ff       	jmp    801068c5 <alltraps>

8010703e <vector30>:
.globl vector30
vector30:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $30
80107040:	6a 1e                	push   $0x1e
  jmp alltraps
80107042:	e9 7e f8 ff ff       	jmp    801068c5 <alltraps>

80107047 <vector31>:
.globl vector31
vector31:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $31
80107049:	6a 1f                	push   $0x1f
  jmp alltraps
8010704b:	e9 75 f8 ff ff       	jmp    801068c5 <alltraps>

80107050 <vector32>:
.globl vector32
vector32:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $32
80107052:	6a 20                	push   $0x20
  jmp alltraps
80107054:	e9 6c f8 ff ff       	jmp    801068c5 <alltraps>

80107059 <vector33>:
.globl vector33
vector33:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $33
8010705b:	6a 21                	push   $0x21
  jmp alltraps
8010705d:	e9 63 f8 ff ff       	jmp    801068c5 <alltraps>

80107062 <vector34>:
.globl vector34
vector34:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $34
80107064:	6a 22                	push   $0x22
  jmp alltraps
80107066:	e9 5a f8 ff ff       	jmp    801068c5 <alltraps>

8010706b <vector35>:
.globl vector35
vector35:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $35
8010706d:	6a 23                	push   $0x23
  jmp alltraps
8010706f:	e9 51 f8 ff ff       	jmp    801068c5 <alltraps>

80107074 <vector36>:
.globl vector36
vector36:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $36
80107076:	6a 24                	push   $0x24
  jmp alltraps
80107078:	e9 48 f8 ff ff       	jmp    801068c5 <alltraps>

8010707d <vector37>:
.globl vector37
vector37:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $37
8010707f:	6a 25                	push   $0x25
  jmp alltraps
80107081:	e9 3f f8 ff ff       	jmp    801068c5 <alltraps>

80107086 <vector38>:
.globl vector38
vector38:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $38
80107088:	6a 26                	push   $0x26
  jmp alltraps
8010708a:	e9 36 f8 ff ff       	jmp    801068c5 <alltraps>

8010708f <vector39>:
.globl vector39
vector39:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $39
80107091:	6a 27                	push   $0x27
  jmp alltraps
80107093:	e9 2d f8 ff ff       	jmp    801068c5 <alltraps>

80107098 <vector40>:
.globl vector40
vector40:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $40
8010709a:	6a 28                	push   $0x28
  jmp alltraps
8010709c:	e9 24 f8 ff ff       	jmp    801068c5 <alltraps>

801070a1 <vector41>:
.globl vector41
vector41:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $41
801070a3:	6a 29                	push   $0x29
  jmp alltraps
801070a5:	e9 1b f8 ff ff       	jmp    801068c5 <alltraps>

801070aa <vector42>:
.globl vector42
vector42:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $42
801070ac:	6a 2a                	push   $0x2a
  jmp alltraps
801070ae:	e9 12 f8 ff ff       	jmp    801068c5 <alltraps>

801070b3 <vector43>:
.globl vector43
vector43:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $43
801070b5:	6a 2b                	push   $0x2b
  jmp alltraps
801070b7:	e9 09 f8 ff ff       	jmp    801068c5 <alltraps>

801070bc <vector44>:
.globl vector44
vector44:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $44
801070be:	6a 2c                	push   $0x2c
  jmp alltraps
801070c0:	e9 00 f8 ff ff       	jmp    801068c5 <alltraps>

801070c5 <vector45>:
.globl vector45
vector45:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $45
801070c7:	6a 2d                	push   $0x2d
  jmp alltraps
801070c9:	e9 f7 f7 ff ff       	jmp    801068c5 <alltraps>

801070ce <vector46>:
.globl vector46
vector46:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $46
801070d0:	6a 2e                	push   $0x2e
  jmp alltraps
801070d2:	e9 ee f7 ff ff       	jmp    801068c5 <alltraps>

801070d7 <vector47>:
.globl vector47
vector47:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $47
801070d9:	6a 2f                	push   $0x2f
  jmp alltraps
801070db:	e9 e5 f7 ff ff       	jmp    801068c5 <alltraps>

801070e0 <vector48>:
.globl vector48
vector48:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $48
801070e2:	6a 30                	push   $0x30
  jmp alltraps
801070e4:	e9 dc f7 ff ff       	jmp    801068c5 <alltraps>

801070e9 <vector49>:
.globl vector49
vector49:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $49
801070eb:	6a 31                	push   $0x31
  jmp alltraps
801070ed:	e9 d3 f7 ff ff       	jmp    801068c5 <alltraps>

801070f2 <vector50>:
.globl vector50
vector50:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $50
801070f4:	6a 32                	push   $0x32
  jmp alltraps
801070f6:	e9 ca f7 ff ff       	jmp    801068c5 <alltraps>

801070fb <vector51>:
.globl vector51
vector51:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $51
801070fd:	6a 33                	push   $0x33
  jmp alltraps
801070ff:	e9 c1 f7 ff ff       	jmp    801068c5 <alltraps>

80107104 <vector52>:
.globl vector52
vector52:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $52
80107106:	6a 34                	push   $0x34
  jmp alltraps
80107108:	e9 b8 f7 ff ff       	jmp    801068c5 <alltraps>

8010710d <vector53>:
.globl vector53
vector53:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $53
8010710f:	6a 35                	push   $0x35
  jmp alltraps
80107111:	e9 af f7 ff ff       	jmp    801068c5 <alltraps>

80107116 <vector54>:
.globl vector54
vector54:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $54
80107118:	6a 36                	push   $0x36
  jmp alltraps
8010711a:	e9 a6 f7 ff ff       	jmp    801068c5 <alltraps>

8010711f <vector55>:
.globl vector55
vector55:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $55
80107121:	6a 37                	push   $0x37
  jmp alltraps
80107123:	e9 9d f7 ff ff       	jmp    801068c5 <alltraps>

80107128 <vector56>:
.globl vector56
vector56:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $56
8010712a:	6a 38                	push   $0x38
  jmp alltraps
8010712c:	e9 94 f7 ff ff       	jmp    801068c5 <alltraps>

80107131 <vector57>:
.globl vector57
vector57:
  pushl $0
80107131:	6a 00                	push   $0x0
  pushl $57
80107133:	6a 39                	push   $0x39
  jmp alltraps
80107135:	e9 8b f7 ff ff       	jmp    801068c5 <alltraps>

8010713a <vector58>:
.globl vector58
vector58:
  pushl $0
8010713a:	6a 00                	push   $0x0
  pushl $58
8010713c:	6a 3a                	push   $0x3a
  jmp alltraps
8010713e:	e9 82 f7 ff ff       	jmp    801068c5 <alltraps>

80107143 <vector59>:
.globl vector59
vector59:
  pushl $0
80107143:	6a 00                	push   $0x0
  pushl $59
80107145:	6a 3b                	push   $0x3b
  jmp alltraps
80107147:	e9 79 f7 ff ff       	jmp    801068c5 <alltraps>

8010714c <vector60>:
.globl vector60
vector60:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $60
8010714e:	6a 3c                	push   $0x3c
  jmp alltraps
80107150:	e9 70 f7 ff ff       	jmp    801068c5 <alltraps>

80107155 <vector61>:
.globl vector61
vector61:
  pushl $0
80107155:	6a 00                	push   $0x0
  pushl $61
80107157:	6a 3d                	push   $0x3d
  jmp alltraps
80107159:	e9 67 f7 ff ff       	jmp    801068c5 <alltraps>

8010715e <vector62>:
.globl vector62
vector62:
  pushl $0
8010715e:	6a 00                	push   $0x0
  pushl $62
80107160:	6a 3e                	push   $0x3e
  jmp alltraps
80107162:	e9 5e f7 ff ff       	jmp    801068c5 <alltraps>

80107167 <vector63>:
.globl vector63
vector63:
  pushl $0
80107167:	6a 00                	push   $0x0
  pushl $63
80107169:	6a 3f                	push   $0x3f
  jmp alltraps
8010716b:	e9 55 f7 ff ff       	jmp    801068c5 <alltraps>

80107170 <vector64>:
.globl vector64
vector64:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $64
80107172:	6a 40                	push   $0x40
  jmp alltraps
80107174:	e9 4c f7 ff ff       	jmp    801068c5 <alltraps>

80107179 <vector65>:
.globl vector65
vector65:
  pushl $0
80107179:	6a 00                	push   $0x0
  pushl $65
8010717b:	6a 41                	push   $0x41
  jmp alltraps
8010717d:	e9 43 f7 ff ff       	jmp    801068c5 <alltraps>

80107182 <vector66>:
.globl vector66
vector66:
  pushl $0
80107182:	6a 00                	push   $0x0
  pushl $66
80107184:	6a 42                	push   $0x42
  jmp alltraps
80107186:	e9 3a f7 ff ff       	jmp    801068c5 <alltraps>

8010718b <vector67>:
.globl vector67
vector67:
  pushl $0
8010718b:	6a 00                	push   $0x0
  pushl $67
8010718d:	6a 43                	push   $0x43
  jmp alltraps
8010718f:	e9 31 f7 ff ff       	jmp    801068c5 <alltraps>

80107194 <vector68>:
.globl vector68
vector68:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $68
80107196:	6a 44                	push   $0x44
  jmp alltraps
80107198:	e9 28 f7 ff ff       	jmp    801068c5 <alltraps>

8010719d <vector69>:
.globl vector69
vector69:
  pushl $0
8010719d:	6a 00                	push   $0x0
  pushl $69
8010719f:	6a 45                	push   $0x45
  jmp alltraps
801071a1:	e9 1f f7 ff ff       	jmp    801068c5 <alltraps>

801071a6 <vector70>:
.globl vector70
vector70:
  pushl $0
801071a6:	6a 00                	push   $0x0
  pushl $70
801071a8:	6a 46                	push   $0x46
  jmp alltraps
801071aa:	e9 16 f7 ff ff       	jmp    801068c5 <alltraps>

801071af <vector71>:
.globl vector71
vector71:
  pushl $0
801071af:	6a 00                	push   $0x0
  pushl $71
801071b1:	6a 47                	push   $0x47
  jmp alltraps
801071b3:	e9 0d f7 ff ff       	jmp    801068c5 <alltraps>

801071b8 <vector72>:
.globl vector72
vector72:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $72
801071ba:	6a 48                	push   $0x48
  jmp alltraps
801071bc:	e9 04 f7 ff ff       	jmp    801068c5 <alltraps>

801071c1 <vector73>:
.globl vector73
vector73:
  pushl $0
801071c1:	6a 00                	push   $0x0
  pushl $73
801071c3:	6a 49                	push   $0x49
  jmp alltraps
801071c5:	e9 fb f6 ff ff       	jmp    801068c5 <alltraps>

801071ca <vector74>:
.globl vector74
vector74:
  pushl $0
801071ca:	6a 00                	push   $0x0
  pushl $74
801071cc:	6a 4a                	push   $0x4a
  jmp alltraps
801071ce:	e9 f2 f6 ff ff       	jmp    801068c5 <alltraps>

801071d3 <vector75>:
.globl vector75
vector75:
  pushl $0
801071d3:	6a 00                	push   $0x0
  pushl $75
801071d5:	6a 4b                	push   $0x4b
  jmp alltraps
801071d7:	e9 e9 f6 ff ff       	jmp    801068c5 <alltraps>

801071dc <vector76>:
.globl vector76
vector76:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $76
801071de:	6a 4c                	push   $0x4c
  jmp alltraps
801071e0:	e9 e0 f6 ff ff       	jmp    801068c5 <alltraps>

801071e5 <vector77>:
.globl vector77
vector77:
  pushl $0
801071e5:	6a 00                	push   $0x0
  pushl $77
801071e7:	6a 4d                	push   $0x4d
  jmp alltraps
801071e9:	e9 d7 f6 ff ff       	jmp    801068c5 <alltraps>

801071ee <vector78>:
.globl vector78
vector78:
  pushl $0
801071ee:	6a 00                	push   $0x0
  pushl $78
801071f0:	6a 4e                	push   $0x4e
  jmp alltraps
801071f2:	e9 ce f6 ff ff       	jmp    801068c5 <alltraps>

801071f7 <vector79>:
.globl vector79
vector79:
  pushl $0
801071f7:	6a 00                	push   $0x0
  pushl $79
801071f9:	6a 4f                	push   $0x4f
  jmp alltraps
801071fb:	e9 c5 f6 ff ff       	jmp    801068c5 <alltraps>

80107200 <vector80>:
.globl vector80
vector80:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $80
80107202:	6a 50                	push   $0x50
  jmp alltraps
80107204:	e9 bc f6 ff ff       	jmp    801068c5 <alltraps>

80107209 <vector81>:
.globl vector81
vector81:
  pushl $0
80107209:	6a 00                	push   $0x0
  pushl $81
8010720b:	6a 51                	push   $0x51
  jmp alltraps
8010720d:	e9 b3 f6 ff ff       	jmp    801068c5 <alltraps>

80107212 <vector82>:
.globl vector82
vector82:
  pushl $0
80107212:	6a 00                	push   $0x0
  pushl $82
80107214:	6a 52                	push   $0x52
  jmp alltraps
80107216:	e9 aa f6 ff ff       	jmp    801068c5 <alltraps>

8010721b <vector83>:
.globl vector83
vector83:
  pushl $0
8010721b:	6a 00                	push   $0x0
  pushl $83
8010721d:	6a 53                	push   $0x53
  jmp alltraps
8010721f:	e9 a1 f6 ff ff       	jmp    801068c5 <alltraps>

80107224 <vector84>:
.globl vector84
vector84:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $84
80107226:	6a 54                	push   $0x54
  jmp alltraps
80107228:	e9 98 f6 ff ff       	jmp    801068c5 <alltraps>

8010722d <vector85>:
.globl vector85
vector85:
  pushl $0
8010722d:	6a 00                	push   $0x0
  pushl $85
8010722f:	6a 55                	push   $0x55
  jmp alltraps
80107231:	e9 8f f6 ff ff       	jmp    801068c5 <alltraps>

80107236 <vector86>:
.globl vector86
vector86:
  pushl $0
80107236:	6a 00                	push   $0x0
  pushl $86
80107238:	6a 56                	push   $0x56
  jmp alltraps
8010723a:	e9 86 f6 ff ff       	jmp    801068c5 <alltraps>

8010723f <vector87>:
.globl vector87
vector87:
  pushl $0
8010723f:	6a 00                	push   $0x0
  pushl $87
80107241:	6a 57                	push   $0x57
  jmp alltraps
80107243:	e9 7d f6 ff ff       	jmp    801068c5 <alltraps>

80107248 <vector88>:
.globl vector88
vector88:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $88
8010724a:	6a 58                	push   $0x58
  jmp alltraps
8010724c:	e9 74 f6 ff ff       	jmp    801068c5 <alltraps>

80107251 <vector89>:
.globl vector89
vector89:
  pushl $0
80107251:	6a 00                	push   $0x0
  pushl $89
80107253:	6a 59                	push   $0x59
  jmp alltraps
80107255:	e9 6b f6 ff ff       	jmp    801068c5 <alltraps>

8010725a <vector90>:
.globl vector90
vector90:
  pushl $0
8010725a:	6a 00                	push   $0x0
  pushl $90
8010725c:	6a 5a                	push   $0x5a
  jmp alltraps
8010725e:	e9 62 f6 ff ff       	jmp    801068c5 <alltraps>

80107263 <vector91>:
.globl vector91
vector91:
  pushl $0
80107263:	6a 00                	push   $0x0
  pushl $91
80107265:	6a 5b                	push   $0x5b
  jmp alltraps
80107267:	e9 59 f6 ff ff       	jmp    801068c5 <alltraps>

8010726c <vector92>:
.globl vector92
vector92:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $92
8010726e:	6a 5c                	push   $0x5c
  jmp alltraps
80107270:	e9 50 f6 ff ff       	jmp    801068c5 <alltraps>

80107275 <vector93>:
.globl vector93
vector93:
  pushl $0
80107275:	6a 00                	push   $0x0
  pushl $93
80107277:	6a 5d                	push   $0x5d
  jmp alltraps
80107279:	e9 47 f6 ff ff       	jmp    801068c5 <alltraps>

8010727e <vector94>:
.globl vector94
vector94:
  pushl $0
8010727e:	6a 00                	push   $0x0
  pushl $94
80107280:	6a 5e                	push   $0x5e
  jmp alltraps
80107282:	e9 3e f6 ff ff       	jmp    801068c5 <alltraps>

80107287 <vector95>:
.globl vector95
vector95:
  pushl $0
80107287:	6a 00                	push   $0x0
  pushl $95
80107289:	6a 5f                	push   $0x5f
  jmp alltraps
8010728b:	e9 35 f6 ff ff       	jmp    801068c5 <alltraps>

80107290 <vector96>:
.globl vector96
vector96:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $96
80107292:	6a 60                	push   $0x60
  jmp alltraps
80107294:	e9 2c f6 ff ff       	jmp    801068c5 <alltraps>

80107299 <vector97>:
.globl vector97
vector97:
  pushl $0
80107299:	6a 00                	push   $0x0
  pushl $97
8010729b:	6a 61                	push   $0x61
  jmp alltraps
8010729d:	e9 23 f6 ff ff       	jmp    801068c5 <alltraps>

801072a2 <vector98>:
.globl vector98
vector98:
  pushl $0
801072a2:	6a 00                	push   $0x0
  pushl $98
801072a4:	6a 62                	push   $0x62
  jmp alltraps
801072a6:	e9 1a f6 ff ff       	jmp    801068c5 <alltraps>

801072ab <vector99>:
.globl vector99
vector99:
  pushl $0
801072ab:	6a 00                	push   $0x0
  pushl $99
801072ad:	6a 63                	push   $0x63
  jmp alltraps
801072af:	e9 11 f6 ff ff       	jmp    801068c5 <alltraps>

801072b4 <vector100>:
.globl vector100
vector100:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $100
801072b6:	6a 64                	push   $0x64
  jmp alltraps
801072b8:	e9 08 f6 ff ff       	jmp    801068c5 <alltraps>

801072bd <vector101>:
.globl vector101
vector101:
  pushl $0
801072bd:	6a 00                	push   $0x0
  pushl $101
801072bf:	6a 65                	push   $0x65
  jmp alltraps
801072c1:	e9 ff f5 ff ff       	jmp    801068c5 <alltraps>

801072c6 <vector102>:
.globl vector102
vector102:
  pushl $0
801072c6:	6a 00                	push   $0x0
  pushl $102
801072c8:	6a 66                	push   $0x66
  jmp alltraps
801072ca:	e9 f6 f5 ff ff       	jmp    801068c5 <alltraps>

801072cf <vector103>:
.globl vector103
vector103:
  pushl $0
801072cf:	6a 00                	push   $0x0
  pushl $103
801072d1:	6a 67                	push   $0x67
  jmp alltraps
801072d3:	e9 ed f5 ff ff       	jmp    801068c5 <alltraps>

801072d8 <vector104>:
.globl vector104
vector104:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $104
801072da:	6a 68                	push   $0x68
  jmp alltraps
801072dc:	e9 e4 f5 ff ff       	jmp    801068c5 <alltraps>

801072e1 <vector105>:
.globl vector105
vector105:
  pushl $0
801072e1:	6a 00                	push   $0x0
  pushl $105
801072e3:	6a 69                	push   $0x69
  jmp alltraps
801072e5:	e9 db f5 ff ff       	jmp    801068c5 <alltraps>

801072ea <vector106>:
.globl vector106
vector106:
  pushl $0
801072ea:	6a 00                	push   $0x0
  pushl $106
801072ec:	6a 6a                	push   $0x6a
  jmp alltraps
801072ee:	e9 d2 f5 ff ff       	jmp    801068c5 <alltraps>

801072f3 <vector107>:
.globl vector107
vector107:
  pushl $0
801072f3:	6a 00                	push   $0x0
  pushl $107
801072f5:	6a 6b                	push   $0x6b
  jmp alltraps
801072f7:	e9 c9 f5 ff ff       	jmp    801068c5 <alltraps>

801072fc <vector108>:
.globl vector108
vector108:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $108
801072fe:	6a 6c                	push   $0x6c
  jmp alltraps
80107300:	e9 c0 f5 ff ff       	jmp    801068c5 <alltraps>

80107305 <vector109>:
.globl vector109
vector109:
  pushl $0
80107305:	6a 00                	push   $0x0
  pushl $109
80107307:	6a 6d                	push   $0x6d
  jmp alltraps
80107309:	e9 b7 f5 ff ff       	jmp    801068c5 <alltraps>

8010730e <vector110>:
.globl vector110
vector110:
  pushl $0
8010730e:	6a 00                	push   $0x0
  pushl $110
80107310:	6a 6e                	push   $0x6e
  jmp alltraps
80107312:	e9 ae f5 ff ff       	jmp    801068c5 <alltraps>

80107317 <vector111>:
.globl vector111
vector111:
  pushl $0
80107317:	6a 00                	push   $0x0
  pushl $111
80107319:	6a 6f                	push   $0x6f
  jmp alltraps
8010731b:	e9 a5 f5 ff ff       	jmp    801068c5 <alltraps>

80107320 <vector112>:
.globl vector112
vector112:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $112
80107322:	6a 70                	push   $0x70
  jmp alltraps
80107324:	e9 9c f5 ff ff       	jmp    801068c5 <alltraps>

80107329 <vector113>:
.globl vector113
vector113:
  pushl $0
80107329:	6a 00                	push   $0x0
  pushl $113
8010732b:	6a 71                	push   $0x71
  jmp alltraps
8010732d:	e9 93 f5 ff ff       	jmp    801068c5 <alltraps>

80107332 <vector114>:
.globl vector114
vector114:
  pushl $0
80107332:	6a 00                	push   $0x0
  pushl $114
80107334:	6a 72                	push   $0x72
  jmp alltraps
80107336:	e9 8a f5 ff ff       	jmp    801068c5 <alltraps>

8010733b <vector115>:
.globl vector115
vector115:
  pushl $0
8010733b:	6a 00                	push   $0x0
  pushl $115
8010733d:	6a 73                	push   $0x73
  jmp alltraps
8010733f:	e9 81 f5 ff ff       	jmp    801068c5 <alltraps>

80107344 <vector116>:
.globl vector116
vector116:
  pushl $0
80107344:	6a 00                	push   $0x0
  pushl $116
80107346:	6a 74                	push   $0x74
  jmp alltraps
80107348:	e9 78 f5 ff ff       	jmp    801068c5 <alltraps>

8010734d <vector117>:
.globl vector117
vector117:
  pushl $0
8010734d:	6a 00                	push   $0x0
  pushl $117
8010734f:	6a 75                	push   $0x75
  jmp alltraps
80107351:	e9 6f f5 ff ff       	jmp    801068c5 <alltraps>

80107356 <vector118>:
.globl vector118
vector118:
  pushl $0
80107356:	6a 00                	push   $0x0
  pushl $118
80107358:	6a 76                	push   $0x76
  jmp alltraps
8010735a:	e9 66 f5 ff ff       	jmp    801068c5 <alltraps>

8010735f <vector119>:
.globl vector119
vector119:
  pushl $0
8010735f:	6a 00                	push   $0x0
  pushl $119
80107361:	6a 77                	push   $0x77
  jmp alltraps
80107363:	e9 5d f5 ff ff       	jmp    801068c5 <alltraps>

80107368 <vector120>:
.globl vector120
vector120:
  pushl $0
80107368:	6a 00                	push   $0x0
  pushl $120
8010736a:	6a 78                	push   $0x78
  jmp alltraps
8010736c:	e9 54 f5 ff ff       	jmp    801068c5 <alltraps>

80107371 <vector121>:
.globl vector121
vector121:
  pushl $0
80107371:	6a 00                	push   $0x0
  pushl $121
80107373:	6a 79                	push   $0x79
  jmp alltraps
80107375:	e9 4b f5 ff ff       	jmp    801068c5 <alltraps>

8010737a <vector122>:
.globl vector122
vector122:
  pushl $0
8010737a:	6a 00                	push   $0x0
  pushl $122
8010737c:	6a 7a                	push   $0x7a
  jmp alltraps
8010737e:	e9 42 f5 ff ff       	jmp    801068c5 <alltraps>

80107383 <vector123>:
.globl vector123
vector123:
  pushl $0
80107383:	6a 00                	push   $0x0
  pushl $123
80107385:	6a 7b                	push   $0x7b
  jmp alltraps
80107387:	e9 39 f5 ff ff       	jmp    801068c5 <alltraps>

8010738c <vector124>:
.globl vector124
vector124:
  pushl $0
8010738c:	6a 00                	push   $0x0
  pushl $124
8010738e:	6a 7c                	push   $0x7c
  jmp alltraps
80107390:	e9 30 f5 ff ff       	jmp    801068c5 <alltraps>

80107395 <vector125>:
.globl vector125
vector125:
  pushl $0
80107395:	6a 00                	push   $0x0
  pushl $125
80107397:	6a 7d                	push   $0x7d
  jmp alltraps
80107399:	e9 27 f5 ff ff       	jmp    801068c5 <alltraps>

8010739e <vector126>:
.globl vector126
vector126:
  pushl $0
8010739e:	6a 00                	push   $0x0
  pushl $126
801073a0:	6a 7e                	push   $0x7e
  jmp alltraps
801073a2:	e9 1e f5 ff ff       	jmp    801068c5 <alltraps>

801073a7 <vector127>:
.globl vector127
vector127:
  pushl $0
801073a7:	6a 00                	push   $0x0
  pushl $127
801073a9:	6a 7f                	push   $0x7f
  jmp alltraps
801073ab:	e9 15 f5 ff ff       	jmp    801068c5 <alltraps>

801073b0 <vector128>:
.globl vector128
vector128:
  pushl $0
801073b0:	6a 00                	push   $0x0
  pushl $128
801073b2:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801073b7:	e9 09 f5 ff ff       	jmp    801068c5 <alltraps>

801073bc <vector129>:
.globl vector129
vector129:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $129
801073be:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801073c3:	e9 fd f4 ff ff       	jmp    801068c5 <alltraps>

801073c8 <vector130>:
.globl vector130
vector130:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $130
801073ca:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801073cf:	e9 f1 f4 ff ff       	jmp    801068c5 <alltraps>

801073d4 <vector131>:
.globl vector131
vector131:
  pushl $0
801073d4:	6a 00                	push   $0x0
  pushl $131
801073d6:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801073db:	e9 e5 f4 ff ff       	jmp    801068c5 <alltraps>

801073e0 <vector132>:
.globl vector132
vector132:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $132
801073e2:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801073e7:	e9 d9 f4 ff ff       	jmp    801068c5 <alltraps>

801073ec <vector133>:
.globl vector133
vector133:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $133
801073ee:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801073f3:	e9 cd f4 ff ff       	jmp    801068c5 <alltraps>

801073f8 <vector134>:
.globl vector134
vector134:
  pushl $0
801073f8:	6a 00                	push   $0x0
  pushl $134
801073fa:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801073ff:	e9 c1 f4 ff ff       	jmp    801068c5 <alltraps>

80107404 <vector135>:
.globl vector135
vector135:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $135
80107406:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010740b:	e9 b5 f4 ff ff       	jmp    801068c5 <alltraps>

80107410 <vector136>:
.globl vector136
vector136:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $136
80107412:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107417:	e9 a9 f4 ff ff       	jmp    801068c5 <alltraps>

8010741c <vector137>:
.globl vector137
vector137:
  pushl $0
8010741c:	6a 00                	push   $0x0
  pushl $137
8010741e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107423:	e9 9d f4 ff ff       	jmp    801068c5 <alltraps>

80107428 <vector138>:
.globl vector138
vector138:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $138
8010742a:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010742f:	e9 91 f4 ff ff       	jmp    801068c5 <alltraps>

80107434 <vector139>:
.globl vector139
vector139:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $139
80107436:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010743b:	e9 85 f4 ff ff       	jmp    801068c5 <alltraps>

80107440 <vector140>:
.globl vector140
vector140:
  pushl $0
80107440:	6a 00                	push   $0x0
  pushl $140
80107442:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107447:	e9 79 f4 ff ff       	jmp    801068c5 <alltraps>

8010744c <vector141>:
.globl vector141
vector141:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $141
8010744e:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107453:	e9 6d f4 ff ff       	jmp    801068c5 <alltraps>

80107458 <vector142>:
.globl vector142
vector142:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $142
8010745a:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010745f:	e9 61 f4 ff ff       	jmp    801068c5 <alltraps>

80107464 <vector143>:
.globl vector143
vector143:
  pushl $0
80107464:	6a 00                	push   $0x0
  pushl $143
80107466:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010746b:	e9 55 f4 ff ff       	jmp    801068c5 <alltraps>

80107470 <vector144>:
.globl vector144
vector144:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $144
80107472:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107477:	e9 49 f4 ff ff       	jmp    801068c5 <alltraps>

8010747c <vector145>:
.globl vector145
vector145:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $145
8010747e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107483:	e9 3d f4 ff ff       	jmp    801068c5 <alltraps>

80107488 <vector146>:
.globl vector146
vector146:
  pushl $0
80107488:	6a 00                	push   $0x0
  pushl $146
8010748a:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010748f:	e9 31 f4 ff ff       	jmp    801068c5 <alltraps>

80107494 <vector147>:
.globl vector147
vector147:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $147
80107496:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010749b:	e9 25 f4 ff ff       	jmp    801068c5 <alltraps>

801074a0 <vector148>:
.globl vector148
vector148:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $148
801074a2:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801074a7:	e9 19 f4 ff ff       	jmp    801068c5 <alltraps>

801074ac <vector149>:
.globl vector149
vector149:
  pushl $0
801074ac:	6a 00                	push   $0x0
  pushl $149
801074ae:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801074b3:	e9 0d f4 ff ff       	jmp    801068c5 <alltraps>

801074b8 <vector150>:
.globl vector150
vector150:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $150
801074ba:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801074bf:	e9 01 f4 ff ff       	jmp    801068c5 <alltraps>

801074c4 <vector151>:
.globl vector151
vector151:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $151
801074c6:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801074cb:	e9 f5 f3 ff ff       	jmp    801068c5 <alltraps>

801074d0 <vector152>:
.globl vector152
vector152:
  pushl $0
801074d0:	6a 00                	push   $0x0
  pushl $152
801074d2:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801074d7:	e9 e9 f3 ff ff       	jmp    801068c5 <alltraps>

801074dc <vector153>:
.globl vector153
vector153:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $153
801074de:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801074e3:	e9 dd f3 ff ff       	jmp    801068c5 <alltraps>

801074e8 <vector154>:
.globl vector154
vector154:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $154
801074ea:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801074ef:	e9 d1 f3 ff ff       	jmp    801068c5 <alltraps>

801074f4 <vector155>:
.globl vector155
vector155:
  pushl $0
801074f4:	6a 00                	push   $0x0
  pushl $155
801074f6:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801074fb:	e9 c5 f3 ff ff       	jmp    801068c5 <alltraps>

80107500 <vector156>:
.globl vector156
vector156:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $156
80107502:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107507:	e9 b9 f3 ff ff       	jmp    801068c5 <alltraps>

8010750c <vector157>:
.globl vector157
vector157:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $157
8010750e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107513:	e9 ad f3 ff ff       	jmp    801068c5 <alltraps>

80107518 <vector158>:
.globl vector158
vector158:
  pushl $0
80107518:	6a 00                	push   $0x0
  pushl $158
8010751a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010751f:	e9 a1 f3 ff ff       	jmp    801068c5 <alltraps>

80107524 <vector159>:
.globl vector159
vector159:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $159
80107526:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010752b:	e9 95 f3 ff ff       	jmp    801068c5 <alltraps>

80107530 <vector160>:
.globl vector160
vector160:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $160
80107532:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107537:	e9 89 f3 ff ff       	jmp    801068c5 <alltraps>

8010753c <vector161>:
.globl vector161
vector161:
  pushl $0
8010753c:	6a 00                	push   $0x0
  pushl $161
8010753e:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107543:	e9 7d f3 ff ff       	jmp    801068c5 <alltraps>

80107548 <vector162>:
.globl vector162
vector162:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $162
8010754a:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010754f:	e9 71 f3 ff ff       	jmp    801068c5 <alltraps>

80107554 <vector163>:
.globl vector163
vector163:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $163
80107556:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010755b:	e9 65 f3 ff ff       	jmp    801068c5 <alltraps>

80107560 <vector164>:
.globl vector164
vector164:
  pushl $0
80107560:	6a 00                	push   $0x0
  pushl $164
80107562:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107567:	e9 59 f3 ff ff       	jmp    801068c5 <alltraps>

8010756c <vector165>:
.globl vector165
vector165:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $165
8010756e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107573:	e9 4d f3 ff ff       	jmp    801068c5 <alltraps>

80107578 <vector166>:
.globl vector166
vector166:
  pushl $0
80107578:	6a 00                	push   $0x0
  pushl $166
8010757a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010757f:	e9 41 f3 ff ff       	jmp    801068c5 <alltraps>

80107584 <vector167>:
.globl vector167
vector167:
  pushl $0
80107584:	6a 00                	push   $0x0
  pushl $167
80107586:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010758b:	e9 35 f3 ff ff       	jmp    801068c5 <alltraps>

80107590 <vector168>:
.globl vector168
vector168:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $168
80107592:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107597:	e9 29 f3 ff ff       	jmp    801068c5 <alltraps>

8010759c <vector169>:
.globl vector169
vector169:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $169
8010759e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801075a3:	e9 1d f3 ff ff       	jmp    801068c5 <alltraps>

801075a8 <vector170>:
.globl vector170
vector170:
  pushl $0
801075a8:	6a 00                	push   $0x0
  pushl $170
801075aa:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801075af:	e9 11 f3 ff ff       	jmp    801068c5 <alltraps>

801075b4 <vector171>:
.globl vector171
vector171:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $171
801075b6:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801075bb:	e9 05 f3 ff ff       	jmp    801068c5 <alltraps>

801075c0 <vector172>:
.globl vector172
vector172:
  pushl $0
801075c0:	6a 00                	push   $0x0
  pushl $172
801075c2:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801075c7:	e9 f9 f2 ff ff       	jmp    801068c5 <alltraps>

801075cc <vector173>:
.globl vector173
vector173:
  pushl $0
801075cc:	6a 00                	push   $0x0
  pushl $173
801075ce:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801075d3:	e9 ed f2 ff ff       	jmp    801068c5 <alltraps>

801075d8 <vector174>:
.globl vector174
vector174:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $174
801075da:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801075df:	e9 e1 f2 ff ff       	jmp    801068c5 <alltraps>

801075e4 <vector175>:
.globl vector175
vector175:
  pushl $0
801075e4:	6a 00                	push   $0x0
  pushl $175
801075e6:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801075eb:	e9 d5 f2 ff ff       	jmp    801068c5 <alltraps>

801075f0 <vector176>:
.globl vector176
vector176:
  pushl $0
801075f0:	6a 00                	push   $0x0
  pushl $176
801075f2:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801075f7:	e9 c9 f2 ff ff       	jmp    801068c5 <alltraps>

801075fc <vector177>:
.globl vector177
vector177:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $177
801075fe:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107603:	e9 bd f2 ff ff       	jmp    801068c5 <alltraps>

80107608 <vector178>:
.globl vector178
vector178:
  pushl $0
80107608:	6a 00                	push   $0x0
  pushl $178
8010760a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010760f:	e9 b1 f2 ff ff       	jmp    801068c5 <alltraps>

80107614 <vector179>:
.globl vector179
vector179:
  pushl $0
80107614:	6a 00                	push   $0x0
  pushl $179
80107616:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010761b:	e9 a5 f2 ff ff       	jmp    801068c5 <alltraps>

80107620 <vector180>:
.globl vector180
vector180:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $180
80107622:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107627:	e9 99 f2 ff ff       	jmp    801068c5 <alltraps>

8010762c <vector181>:
.globl vector181
vector181:
  pushl $0
8010762c:	6a 00                	push   $0x0
  pushl $181
8010762e:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107633:	e9 8d f2 ff ff       	jmp    801068c5 <alltraps>

80107638 <vector182>:
.globl vector182
vector182:
  pushl $0
80107638:	6a 00                	push   $0x0
  pushl $182
8010763a:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010763f:	e9 81 f2 ff ff       	jmp    801068c5 <alltraps>

80107644 <vector183>:
.globl vector183
vector183:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $183
80107646:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010764b:	e9 75 f2 ff ff       	jmp    801068c5 <alltraps>

80107650 <vector184>:
.globl vector184
vector184:
  pushl $0
80107650:	6a 00                	push   $0x0
  pushl $184
80107652:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107657:	e9 69 f2 ff ff       	jmp    801068c5 <alltraps>

8010765c <vector185>:
.globl vector185
vector185:
  pushl $0
8010765c:	6a 00                	push   $0x0
  pushl $185
8010765e:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107663:	e9 5d f2 ff ff       	jmp    801068c5 <alltraps>

80107668 <vector186>:
.globl vector186
vector186:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $186
8010766a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010766f:	e9 51 f2 ff ff       	jmp    801068c5 <alltraps>

80107674 <vector187>:
.globl vector187
vector187:
  pushl $0
80107674:	6a 00                	push   $0x0
  pushl $187
80107676:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010767b:	e9 45 f2 ff ff       	jmp    801068c5 <alltraps>

80107680 <vector188>:
.globl vector188
vector188:
  pushl $0
80107680:	6a 00                	push   $0x0
  pushl $188
80107682:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107687:	e9 39 f2 ff ff       	jmp    801068c5 <alltraps>

8010768c <vector189>:
.globl vector189
vector189:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $189
8010768e:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107693:	e9 2d f2 ff ff       	jmp    801068c5 <alltraps>

80107698 <vector190>:
.globl vector190
vector190:
  pushl $0
80107698:	6a 00                	push   $0x0
  pushl $190
8010769a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010769f:	e9 21 f2 ff ff       	jmp    801068c5 <alltraps>

801076a4 <vector191>:
.globl vector191
vector191:
  pushl $0
801076a4:	6a 00                	push   $0x0
  pushl $191
801076a6:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801076ab:	e9 15 f2 ff ff       	jmp    801068c5 <alltraps>

801076b0 <vector192>:
.globl vector192
vector192:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $192
801076b2:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801076b7:	e9 09 f2 ff ff       	jmp    801068c5 <alltraps>

801076bc <vector193>:
.globl vector193
vector193:
  pushl $0
801076bc:	6a 00                	push   $0x0
  pushl $193
801076be:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801076c3:	e9 fd f1 ff ff       	jmp    801068c5 <alltraps>

801076c8 <vector194>:
.globl vector194
vector194:
  pushl $0
801076c8:	6a 00                	push   $0x0
  pushl $194
801076ca:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801076cf:	e9 f1 f1 ff ff       	jmp    801068c5 <alltraps>

801076d4 <vector195>:
.globl vector195
vector195:
  pushl $0
801076d4:	6a 00                	push   $0x0
  pushl $195
801076d6:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801076db:	e9 e5 f1 ff ff       	jmp    801068c5 <alltraps>

801076e0 <vector196>:
.globl vector196
vector196:
  pushl $0
801076e0:	6a 00                	push   $0x0
  pushl $196
801076e2:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801076e7:	e9 d9 f1 ff ff       	jmp    801068c5 <alltraps>

801076ec <vector197>:
.globl vector197
vector197:
  pushl $0
801076ec:	6a 00                	push   $0x0
  pushl $197
801076ee:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801076f3:	e9 cd f1 ff ff       	jmp    801068c5 <alltraps>

801076f8 <vector198>:
.globl vector198
vector198:
  pushl $0
801076f8:	6a 00                	push   $0x0
  pushl $198
801076fa:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801076ff:	e9 c1 f1 ff ff       	jmp    801068c5 <alltraps>

80107704 <vector199>:
.globl vector199
vector199:
  pushl $0
80107704:	6a 00                	push   $0x0
  pushl $199
80107706:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010770b:	e9 b5 f1 ff ff       	jmp    801068c5 <alltraps>

80107710 <vector200>:
.globl vector200
vector200:
  pushl $0
80107710:	6a 00                	push   $0x0
  pushl $200
80107712:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107717:	e9 a9 f1 ff ff       	jmp    801068c5 <alltraps>

8010771c <vector201>:
.globl vector201
vector201:
  pushl $0
8010771c:	6a 00                	push   $0x0
  pushl $201
8010771e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107723:	e9 9d f1 ff ff       	jmp    801068c5 <alltraps>

80107728 <vector202>:
.globl vector202
vector202:
  pushl $0
80107728:	6a 00                	push   $0x0
  pushl $202
8010772a:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010772f:	e9 91 f1 ff ff       	jmp    801068c5 <alltraps>

80107734 <vector203>:
.globl vector203
vector203:
  pushl $0
80107734:	6a 00                	push   $0x0
  pushl $203
80107736:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010773b:	e9 85 f1 ff ff       	jmp    801068c5 <alltraps>

80107740 <vector204>:
.globl vector204
vector204:
  pushl $0
80107740:	6a 00                	push   $0x0
  pushl $204
80107742:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107747:	e9 79 f1 ff ff       	jmp    801068c5 <alltraps>

8010774c <vector205>:
.globl vector205
vector205:
  pushl $0
8010774c:	6a 00                	push   $0x0
  pushl $205
8010774e:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107753:	e9 6d f1 ff ff       	jmp    801068c5 <alltraps>

80107758 <vector206>:
.globl vector206
vector206:
  pushl $0
80107758:	6a 00                	push   $0x0
  pushl $206
8010775a:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010775f:	e9 61 f1 ff ff       	jmp    801068c5 <alltraps>

80107764 <vector207>:
.globl vector207
vector207:
  pushl $0
80107764:	6a 00                	push   $0x0
  pushl $207
80107766:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010776b:	e9 55 f1 ff ff       	jmp    801068c5 <alltraps>

80107770 <vector208>:
.globl vector208
vector208:
  pushl $0
80107770:	6a 00                	push   $0x0
  pushl $208
80107772:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107777:	e9 49 f1 ff ff       	jmp    801068c5 <alltraps>

8010777c <vector209>:
.globl vector209
vector209:
  pushl $0
8010777c:	6a 00                	push   $0x0
  pushl $209
8010777e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107783:	e9 3d f1 ff ff       	jmp    801068c5 <alltraps>

80107788 <vector210>:
.globl vector210
vector210:
  pushl $0
80107788:	6a 00                	push   $0x0
  pushl $210
8010778a:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010778f:	e9 31 f1 ff ff       	jmp    801068c5 <alltraps>

80107794 <vector211>:
.globl vector211
vector211:
  pushl $0
80107794:	6a 00                	push   $0x0
  pushl $211
80107796:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010779b:	e9 25 f1 ff ff       	jmp    801068c5 <alltraps>

801077a0 <vector212>:
.globl vector212
vector212:
  pushl $0
801077a0:	6a 00                	push   $0x0
  pushl $212
801077a2:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801077a7:	e9 19 f1 ff ff       	jmp    801068c5 <alltraps>

801077ac <vector213>:
.globl vector213
vector213:
  pushl $0
801077ac:	6a 00                	push   $0x0
  pushl $213
801077ae:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801077b3:	e9 0d f1 ff ff       	jmp    801068c5 <alltraps>

801077b8 <vector214>:
.globl vector214
vector214:
  pushl $0
801077b8:	6a 00                	push   $0x0
  pushl $214
801077ba:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801077bf:	e9 01 f1 ff ff       	jmp    801068c5 <alltraps>

801077c4 <vector215>:
.globl vector215
vector215:
  pushl $0
801077c4:	6a 00                	push   $0x0
  pushl $215
801077c6:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801077cb:	e9 f5 f0 ff ff       	jmp    801068c5 <alltraps>

801077d0 <vector216>:
.globl vector216
vector216:
  pushl $0
801077d0:	6a 00                	push   $0x0
  pushl $216
801077d2:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801077d7:	e9 e9 f0 ff ff       	jmp    801068c5 <alltraps>

801077dc <vector217>:
.globl vector217
vector217:
  pushl $0
801077dc:	6a 00                	push   $0x0
  pushl $217
801077de:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801077e3:	e9 dd f0 ff ff       	jmp    801068c5 <alltraps>

801077e8 <vector218>:
.globl vector218
vector218:
  pushl $0
801077e8:	6a 00                	push   $0x0
  pushl $218
801077ea:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801077ef:	e9 d1 f0 ff ff       	jmp    801068c5 <alltraps>

801077f4 <vector219>:
.globl vector219
vector219:
  pushl $0
801077f4:	6a 00                	push   $0x0
  pushl $219
801077f6:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801077fb:	e9 c5 f0 ff ff       	jmp    801068c5 <alltraps>

80107800 <vector220>:
.globl vector220
vector220:
  pushl $0
80107800:	6a 00                	push   $0x0
  pushl $220
80107802:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107807:	e9 b9 f0 ff ff       	jmp    801068c5 <alltraps>

8010780c <vector221>:
.globl vector221
vector221:
  pushl $0
8010780c:	6a 00                	push   $0x0
  pushl $221
8010780e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107813:	e9 ad f0 ff ff       	jmp    801068c5 <alltraps>

80107818 <vector222>:
.globl vector222
vector222:
  pushl $0
80107818:	6a 00                	push   $0x0
  pushl $222
8010781a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010781f:	e9 a1 f0 ff ff       	jmp    801068c5 <alltraps>

80107824 <vector223>:
.globl vector223
vector223:
  pushl $0
80107824:	6a 00                	push   $0x0
  pushl $223
80107826:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010782b:	e9 95 f0 ff ff       	jmp    801068c5 <alltraps>

80107830 <vector224>:
.globl vector224
vector224:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $224
80107832:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107837:	e9 89 f0 ff ff       	jmp    801068c5 <alltraps>

8010783c <vector225>:
.globl vector225
vector225:
  pushl $0
8010783c:	6a 00                	push   $0x0
  pushl $225
8010783e:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107843:	e9 7d f0 ff ff       	jmp    801068c5 <alltraps>

80107848 <vector226>:
.globl vector226
vector226:
  pushl $0
80107848:	6a 00                	push   $0x0
  pushl $226
8010784a:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010784f:	e9 71 f0 ff ff       	jmp    801068c5 <alltraps>

80107854 <vector227>:
.globl vector227
vector227:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $227
80107856:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010785b:	e9 65 f0 ff ff       	jmp    801068c5 <alltraps>

80107860 <vector228>:
.globl vector228
vector228:
  pushl $0
80107860:	6a 00                	push   $0x0
  pushl $228
80107862:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107867:	e9 59 f0 ff ff       	jmp    801068c5 <alltraps>

8010786c <vector229>:
.globl vector229
vector229:
  pushl $0
8010786c:	6a 00                	push   $0x0
  pushl $229
8010786e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107873:	e9 4d f0 ff ff       	jmp    801068c5 <alltraps>

80107878 <vector230>:
.globl vector230
vector230:
  pushl $0
80107878:	6a 00                	push   $0x0
  pushl $230
8010787a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010787f:	e9 41 f0 ff ff       	jmp    801068c5 <alltraps>

80107884 <vector231>:
.globl vector231
vector231:
  pushl $0
80107884:	6a 00                	push   $0x0
  pushl $231
80107886:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010788b:	e9 35 f0 ff ff       	jmp    801068c5 <alltraps>

80107890 <vector232>:
.globl vector232
vector232:
  pushl $0
80107890:	6a 00                	push   $0x0
  pushl $232
80107892:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107897:	e9 29 f0 ff ff       	jmp    801068c5 <alltraps>

8010789c <vector233>:
.globl vector233
vector233:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $233
8010789e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801078a3:	e9 1d f0 ff ff       	jmp    801068c5 <alltraps>

801078a8 <vector234>:
.globl vector234
vector234:
  pushl $0
801078a8:	6a 00                	push   $0x0
  pushl $234
801078aa:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801078af:	e9 11 f0 ff ff       	jmp    801068c5 <alltraps>

801078b4 <vector235>:
.globl vector235
vector235:
  pushl $0
801078b4:	6a 00                	push   $0x0
  pushl $235
801078b6:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801078bb:	e9 05 f0 ff ff       	jmp    801068c5 <alltraps>

801078c0 <vector236>:
.globl vector236
vector236:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $236
801078c2:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801078c7:	e9 f9 ef ff ff       	jmp    801068c5 <alltraps>

801078cc <vector237>:
.globl vector237
vector237:
  pushl $0
801078cc:	6a 00                	push   $0x0
  pushl $237
801078ce:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801078d3:	e9 ed ef ff ff       	jmp    801068c5 <alltraps>

801078d8 <vector238>:
.globl vector238
vector238:
  pushl $0
801078d8:	6a 00                	push   $0x0
  pushl $238
801078da:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801078df:	e9 e1 ef ff ff       	jmp    801068c5 <alltraps>

801078e4 <vector239>:
.globl vector239
vector239:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $239
801078e6:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801078eb:	e9 d5 ef ff ff       	jmp    801068c5 <alltraps>

801078f0 <vector240>:
.globl vector240
vector240:
  pushl $0
801078f0:	6a 00                	push   $0x0
  pushl $240
801078f2:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801078f7:	e9 c9 ef ff ff       	jmp    801068c5 <alltraps>

801078fc <vector241>:
.globl vector241
vector241:
  pushl $0
801078fc:	6a 00                	push   $0x0
  pushl $241
801078fe:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107903:	e9 bd ef ff ff       	jmp    801068c5 <alltraps>

80107908 <vector242>:
.globl vector242
vector242:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $242
8010790a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010790f:	e9 b1 ef ff ff       	jmp    801068c5 <alltraps>

80107914 <vector243>:
.globl vector243
vector243:
  pushl $0
80107914:	6a 00                	push   $0x0
  pushl $243
80107916:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010791b:	e9 a5 ef ff ff       	jmp    801068c5 <alltraps>

80107920 <vector244>:
.globl vector244
vector244:
  pushl $0
80107920:	6a 00                	push   $0x0
  pushl $244
80107922:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107927:	e9 99 ef ff ff       	jmp    801068c5 <alltraps>

8010792c <vector245>:
.globl vector245
vector245:
  pushl $0
8010792c:	6a 00                	push   $0x0
  pushl $245
8010792e:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107933:	e9 8d ef ff ff       	jmp    801068c5 <alltraps>

80107938 <vector246>:
.globl vector246
vector246:
  pushl $0
80107938:	6a 00                	push   $0x0
  pushl $246
8010793a:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010793f:	e9 81 ef ff ff       	jmp    801068c5 <alltraps>

80107944 <vector247>:
.globl vector247
vector247:
  pushl $0
80107944:	6a 00                	push   $0x0
  pushl $247
80107946:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010794b:	e9 75 ef ff ff       	jmp    801068c5 <alltraps>

80107950 <vector248>:
.globl vector248
vector248:
  pushl $0
80107950:	6a 00                	push   $0x0
  pushl $248
80107952:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107957:	e9 69 ef ff ff       	jmp    801068c5 <alltraps>

8010795c <vector249>:
.globl vector249
vector249:
  pushl $0
8010795c:	6a 00                	push   $0x0
  pushl $249
8010795e:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107963:	e9 5d ef ff ff       	jmp    801068c5 <alltraps>

80107968 <vector250>:
.globl vector250
vector250:
  pushl $0
80107968:	6a 00                	push   $0x0
  pushl $250
8010796a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010796f:	e9 51 ef ff ff       	jmp    801068c5 <alltraps>

80107974 <vector251>:
.globl vector251
vector251:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $251
80107976:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010797b:	e9 45 ef ff ff       	jmp    801068c5 <alltraps>

80107980 <vector252>:
.globl vector252
vector252:
  pushl $0
80107980:	6a 00                	push   $0x0
  pushl $252
80107982:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107987:	e9 39 ef ff ff       	jmp    801068c5 <alltraps>

8010798c <vector253>:
.globl vector253
vector253:
  pushl $0
8010798c:	6a 00                	push   $0x0
  pushl $253
8010798e:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107993:	e9 2d ef ff ff       	jmp    801068c5 <alltraps>

80107998 <vector254>:
.globl vector254
vector254:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $254
8010799a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010799f:	e9 21 ef ff ff       	jmp    801068c5 <alltraps>

801079a4 <vector255>:
.globl vector255
vector255:
  pushl $0
801079a4:	6a 00                	push   $0x0
  pushl $255
801079a6:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801079ab:	e9 15 ef ff ff       	jmp    801068c5 <alltraps>

801079b0 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801079b0:	55                   	push   %ebp
801079b1:	89 e5                	mov    %esp,%ebp
801079b3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801079b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801079b9:	83 e8 01             	sub    $0x1,%eax
801079bc:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801079c0:	8b 45 08             	mov    0x8(%ebp),%eax
801079c3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801079c7:	8b 45 08             	mov    0x8(%ebp),%eax
801079ca:	c1 e8 10             	shr    $0x10,%eax
801079cd:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801079d1:	8d 45 fa             	lea    -0x6(%ebp),%eax
801079d4:	0f 01 10             	lgdtl  (%eax)
}
801079d7:	c9                   	leave  
801079d8:	c3                   	ret    

801079d9 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801079d9:	55                   	push   %ebp
801079da:	89 e5                	mov    %esp,%ebp
801079dc:	83 ec 04             	sub    $0x4,%esp
801079df:	8b 45 08             	mov    0x8(%ebp),%eax
801079e2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801079e6:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801079ea:	0f 00 d8             	ltr    %ax
}
801079ed:	c9                   	leave  
801079ee:	c3                   	ret    

801079ef <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
801079ef:	55                   	push   %ebp
801079f0:	89 e5                	mov    %esp,%ebp
801079f2:	83 ec 04             	sub    $0x4,%esp
801079f5:	8b 45 08             	mov    0x8(%ebp),%eax
801079f8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801079fc:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107a00:	8e e8                	mov    %eax,%gs
}
80107a02:	c9                   	leave  
80107a03:	c3                   	ret    

80107a04 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107a04:	55                   	push   %ebp
80107a05:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a07:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0a:	0f 22 d8             	mov    %eax,%cr3
}
80107a0d:	5d                   	pop    %ebp
80107a0e:	c3                   	ret    

80107a0f <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107a0f:	55                   	push   %ebp
80107a10:	89 e5                	mov    %esp,%ebp
80107a12:	8b 45 08             	mov    0x8(%ebp),%eax
80107a15:	05 00 00 00 80       	add    $0x80000000,%eax
80107a1a:	5d                   	pop    %ebp
80107a1b:	c3                   	ret    

80107a1c <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107a1c:	55                   	push   %ebp
80107a1d:	89 e5                	mov    %esp,%ebp
80107a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80107a22:	05 00 00 00 80       	add    $0x80000000,%eax
80107a27:	5d                   	pop    %ebp
80107a28:	c3                   	ret    

80107a29 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107a29:	55                   	push   %ebp
80107a2a:	89 e5                	mov    %esp,%ebp
80107a2c:	53                   	push   %ebx
80107a2d:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107a30:	e8 86 b5 ff ff       	call   80102fbb <cpunum>
80107a35:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107a3b:	05 40 f9 10 80       	add    $0x8010f940,%eax
80107a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a58:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a63:	83 e2 f0             	and    $0xfffffff0,%edx
80107a66:	83 ca 0a             	or     $0xa,%edx
80107a69:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6f:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a73:	83 ca 10             	or     $0x10,%edx
80107a76:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7c:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a80:	83 e2 9f             	and    $0xffffff9f,%edx
80107a83:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a89:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a8d:	83 ca 80             	or     $0xffffff80,%edx
80107a90:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a96:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a9a:	83 ca 0f             	or     $0xf,%edx
80107a9d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa3:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107aa7:	83 e2 ef             	and    $0xffffffef,%edx
80107aaa:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab0:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ab4:	83 e2 df             	and    $0xffffffdf,%edx
80107ab7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ac1:	83 ca 40             	or     $0x40,%edx
80107ac4:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aca:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ace:	83 ca 80             	or     $0xffffff80,%edx
80107ad1:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ade:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107ae5:	ff ff 
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107af1:	00 00 
80107af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af6:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b00:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b07:	83 e2 f0             	and    $0xfffffff0,%edx
80107b0a:	83 ca 02             	or     $0x2,%edx
80107b0d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b16:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b1d:	83 ca 10             	or     $0x10,%edx
80107b20:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b29:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b30:	83 e2 9f             	and    $0xffffff9f,%edx
80107b33:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107b43:	83 ca 80             	or     $0xffffff80,%edx
80107b46:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b56:	83 ca 0f             	or     $0xf,%edx
80107b59:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b69:	83 e2 ef             	and    $0xffffffef,%edx
80107b6c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b75:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b7c:	83 e2 df             	and    $0xffffffdf,%edx
80107b7f:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b88:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b8f:	83 ca 40             	or     $0x40,%edx
80107b92:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9b:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ba2:	83 ca 80             	or     $0xffffff80,%edx
80107ba5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bae:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb8:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107bbf:	ff ff 
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107bcb:	00 00 
80107bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd0:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bda:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107be1:	83 e2 f0             	and    $0xfffffff0,%edx
80107be4:	83 ca 0a             	or     $0xa,%edx
80107be7:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf0:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107bf7:	83 ca 10             	or     $0x10,%edx
80107bfa:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c03:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c0a:	83 ca 60             	or     $0x60,%edx
80107c0d:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c16:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107c1d:	83 ca 80             	or     $0xffffff80,%edx
80107c20:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c29:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c30:	83 ca 0f             	or     $0xf,%edx
80107c33:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c43:	83 e2 ef             	and    $0xffffffef,%edx
80107c46:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c56:	83 e2 df             	and    $0xffffffdf,%edx
80107c59:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c62:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c69:	83 ca 40             	or     $0x40,%edx
80107c6c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c75:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c7c:	83 ca 80             	or     $0xffffff80,%edx
80107c7f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c88:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c92:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107c99:	ff ff 
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9e:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107ca5:	00 00 
80107ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107caa:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb4:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cbb:	83 e2 f0             	and    $0xfffffff0,%edx
80107cbe:	83 ca 02             	or     $0x2,%edx
80107cc1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cca:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cd1:	83 ca 10             	or     $0x10,%edx
80107cd4:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cdd:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107ce4:	83 ca 60             	or     $0x60,%edx
80107ce7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf0:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107cf7:	83 ca 80             	or     $0xffffff80,%edx
80107cfa:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d03:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d0a:	83 ca 0f             	or     $0xf,%edx
80107d0d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d1d:	83 e2 ef             	and    $0xffffffef,%edx
80107d20:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d29:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d30:	83 e2 df             	and    $0xffffffdf,%edx
80107d33:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d3c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d43:	83 ca 40             	or     $0x40,%edx
80107d46:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107d56:	83 ca 80             	or     $0xffffff80,%edx
80107d59:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d62:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6c:	05 b4 00 00 00       	add    $0xb4,%eax
80107d71:	89 c3                	mov    %eax,%ebx
80107d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d76:	05 b4 00 00 00       	add    $0xb4,%eax
80107d7b:	c1 e8 10             	shr    $0x10,%eax
80107d7e:	89 c1                	mov    %eax,%ecx
80107d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d83:	05 b4 00 00 00       	add    $0xb4,%eax
80107d88:	c1 e8 18             	shr    $0x18,%eax
80107d8b:	89 c2                	mov    %eax,%edx
80107d8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d90:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107d97:	00 00 
80107d99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d9c:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107daf:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107db6:	83 e1 f0             	and    $0xfffffff0,%ecx
80107db9:	83 c9 02             	or     $0x2,%ecx
80107dbc:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc5:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107dcc:	83 c9 10             	or     $0x10,%ecx
80107dcf:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd8:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107ddf:	83 e1 9f             	and    $0xffffff9f,%ecx
80107de2:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107deb:	0f b6 88 8d 00 00 00 	movzbl 0x8d(%eax),%ecx
80107df2:	83 c9 80             	or     $0xffffff80,%ecx
80107df5:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dfe:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e05:	83 e1 f0             	and    $0xfffffff0,%ecx
80107e08:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e11:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e18:	83 e1 ef             	and    $0xffffffef,%ecx
80107e1b:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e24:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e2b:	83 e1 df             	and    $0xffffffdf,%ecx
80107e2e:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e37:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e3e:	83 c9 40             	or     $0x40,%ecx
80107e41:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4a:	0f b6 88 8e 00 00 00 	movzbl 0x8e(%eax),%ecx
80107e51:	83 c9 80             	or     $0xffffff80,%ecx
80107e54:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
80107e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5d:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e66:	83 c0 70             	add    $0x70,%eax
80107e69:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
80107e70:	00 
80107e71:	89 04 24             	mov    %eax,(%esp)
80107e74:	e8 37 fb ff ff       	call   801079b0 <lgdt>
  loadgs(SEG_KCPU << 3);
80107e79:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
80107e80:	e8 6a fb ff ff       	call   801079ef <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107e85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e88:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107e8e:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107e95:	00 00 00 00 
}
80107e99:	83 c4 24             	add    $0x24,%esp
80107e9c:	5b                   	pop    %ebx
80107e9d:	5d                   	pop    %ebp
80107e9e:	c3                   	ret    

80107e9f <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e9f:	55                   	push   %ebp
80107ea0:	89 e5                	mov    %esp,%ebp
80107ea2:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ea8:	c1 e8 16             	shr    $0x16,%eax
80107eab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80107eb5:	01 d0                	add    %edx,%eax
80107eb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ebd:	8b 00                	mov    (%eax),%eax
80107ebf:	83 e0 01             	and    $0x1,%eax
80107ec2:	85 c0                	test   %eax,%eax
80107ec4:	74 17                	je     80107edd <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ec9:	8b 00                	mov    (%eax),%eax
80107ecb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ed0:	89 04 24             	mov    %eax,(%esp)
80107ed3:	e8 44 fb ff ff       	call   80107a1c <p2v>
80107ed8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107edb:	eb 4b                	jmp    80107f28 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107edd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107ee1:	74 0e                	je     80107ef1 <walkpgdir+0x52>
80107ee3:	e8 5a ad ff ff       	call   80102c42 <kalloc>
80107ee8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107eeb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107eef:	75 07                	jne    80107ef8 <walkpgdir+0x59>
      return 0;
80107ef1:	b8 00 00 00 00       	mov    $0x0,%eax
80107ef6:	eb 47                	jmp    80107f3f <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107ef8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107eff:	00 
80107f00:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f07:	00 
80107f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0b:	89 04 24             	mov    %eax,(%esp)
80107f0e:	e8 5e d3 ff ff       	call   80105271 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f16:	89 04 24             	mov    %eax,(%esp)
80107f19:	e8 f1 fa ff ff       	call   80107a0f <v2p>
80107f1e:	83 c8 07             	or     $0x7,%eax
80107f21:	89 c2                	mov    %eax,%edx
80107f23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f26:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107f28:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f2b:	c1 e8 0c             	shr    $0xc,%eax
80107f2e:	25 ff 03 00 00       	and    $0x3ff,%eax
80107f33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f3d:	01 d0                	add    %edx,%eax
}
80107f3f:	c9                   	leave  
80107f40:	c3                   	ret    

80107f41 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107f41:	55                   	push   %ebp
80107f42:	89 e5                	mov    %esp,%ebp
80107f44:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107f47:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107f52:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f55:	8b 45 10             	mov    0x10(%ebp),%eax
80107f58:	01 d0                	add    %edx,%eax
80107f5a:	83 e8 01             	sub    $0x1,%eax
80107f5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f65:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107f6c:	00 
80107f6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f70:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f74:	8b 45 08             	mov    0x8(%ebp),%eax
80107f77:	89 04 24             	mov    %eax,(%esp)
80107f7a:	e8 20 ff ff ff       	call   80107e9f <walkpgdir>
80107f7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f82:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f86:	75 07                	jne    80107f8f <mappages+0x4e>
      return -1;
80107f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f8d:	eb 48                	jmp    80107fd7 <mappages+0x96>
    if(*pte & PTE_P)
80107f8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f92:	8b 00                	mov    (%eax),%eax
80107f94:	83 e0 01             	and    $0x1,%eax
80107f97:	85 c0                	test   %eax,%eax
80107f99:	74 0c                	je     80107fa7 <mappages+0x66>
      panic("remap");
80107f9b:	c7 04 24 e0 8d 10 80 	movl   $0x80108de0,(%esp)
80107fa2:	e8 93 85 ff ff       	call   8010053a <panic>
    *pte = pa | perm | PTE_P;
80107fa7:	8b 45 18             	mov    0x18(%ebp),%eax
80107faa:	0b 45 14             	or     0x14(%ebp),%eax
80107fad:	83 c8 01             	or     $0x1,%eax
80107fb0:	89 c2                	mov    %eax,%edx
80107fb2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fb5:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fba:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107fbd:	75 08                	jne    80107fc7 <mappages+0x86>
      break;
80107fbf:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107fc0:	b8 00 00 00 00       	mov    $0x0,%eax
80107fc5:	eb 10                	jmp    80107fd7 <mappages+0x96>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107fc7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107fce:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107fd5:	eb 8e                	jmp    80107f65 <mappages+0x24>
  return 0;
}
80107fd7:	c9                   	leave  
80107fd8:	c3                   	ret    

80107fd9 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107fd9:	55                   	push   %ebp
80107fda:	89 e5                	mov    %esp,%ebp
80107fdc:	53                   	push   %ebx
80107fdd:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107fe0:	e8 5d ac ff ff       	call   80102c42 <kalloc>
80107fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107fe8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fec:	75 0a                	jne    80107ff8 <setupkvm+0x1f>
    return 0;
80107fee:	b8 00 00 00 00       	mov    $0x0,%eax
80107ff3:	e9 98 00 00 00       	jmp    80108090 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
80107ff8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107fff:	00 
80108000:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108007:	00 
80108008:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010800b:	89 04 24             	mov    %eax,(%esp)
8010800e:	e8 5e d2 ff ff       	call   80105271 <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108013:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
8010801a:	e8 fd f9 ff ff       	call   80107a1c <p2v>
8010801f:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108024:	76 0c                	jbe    80108032 <setupkvm+0x59>
    panic("PHYSTOP too high");
80108026:	c7 04 24 e6 8d 10 80 	movl   $0x80108de6,(%esp)
8010802d:	e8 08 85 ff ff       	call   8010053a <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108032:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80108039:	eb 49                	jmp    80108084 <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010803b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803e:	8b 48 0c             	mov    0xc(%eax),%ecx
80108041:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108044:	8b 50 04             	mov    0x4(%eax),%edx
80108047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804a:	8b 58 08             	mov    0x8(%eax),%ebx
8010804d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108050:	8b 40 04             	mov    0x4(%eax),%eax
80108053:	29 c3                	sub    %eax,%ebx
80108055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108058:	8b 00                	mov    (%eax),%eax
8010805a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010805e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108066:	89 44 24 04          	mov    %eax,0x4(%esp)
8010806a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010806d:	89 04 24             	mov    %eax,(%esp)
80108070:	e8 cc fe ff ff       	call   80107f41 <mappages>
80108075:	85 c0                	test   %eax,%eax
80108077:	79 07                	jns    80108080 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108079:	b8 00 00 00 00       	mov    $0x0,%eax
8010807e:	eb 10                	jmp    80108090 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108080:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108084:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
8010808b:	72 ae                	jb     8010803b <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
8010808d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108090:	83 c4 34             	add    $0x34,%esp
80108093:	5b                   	pop    %ebx
80108094:	5d                   	pop    %ebp
80108095:	c3                   	ret    

80108096 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108096:	55                   	push   %ebp
80108097:	89 e5                	mov    %esp,%ebp
80108099:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010809c:	e8 38 ff ff ff       	call   80107fd9 <setupkvm>
801080a1:	a3 38 94 11 80       	mov    %eax,0x80119438
  switchkvm();
801080a6:	e8 02 00 00 00       	call   801080ad <switchkvm>
}
801080ab:	c9                   	leave  
801080ac:	c3                   	ret    

801080ad <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801080ad:	55                   	push   %ebp
801080ae:	89 e5                	mov    %esp,%ebp
801080b0:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801080b3:	a1 38 94 11 80       	mov    0x80119438,%eax
801080b8:	89 04 24             	mov    %eax,(%esp)
801080bb:	e8 4f f9 ff ff       	call   80107a0f <v2p>
801080c0:	89 04 24             	mov    %eax,(%esp)
801080c3:	e8 3c f9 ff ff       	call   80107a04 <lcr3>
}
801080c8:	c9                   	leave  
801080c9:	c3                   	ret    

801080ca <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801080ca:	55                   	push   %ebp
801080cb:	89 e5                	mov    %esp,%ebp
801080cd:	53                   	push   %ebx
801080ce:	83 ec 14             	sub    $0x14,%esp
  pushcli();
801080d1:	e8 9b d0 ff ff       	call   80105171 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801080d6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801080dc:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080e3:	83 c2 08             	add    $0x8,%edx
801080e6:	89 d3                	mov    %edx,%ebx
801080e8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080ef:	83 c2 08             	add    $0x8,%edx
801080f2:	c1 ea 10             	shr    $0x10,%edx
801080f5:	89 d1                	mov    %edx,%ecx
801080f7:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801080fe:	83 c2 08             	add    $0x8,%edx
80108101:	c1 ea 18             	shr    $0x18,%edx
80108104:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010810b:	67 00 
8010810d:	66 89 98 a2 00 00 00 	mov    %bx,0xa2(%eax)
80108114:	88 88 a4 00 00 00    	mov    %cl,0xa4(%eax)
8010811a:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108121:	83 e1 f0             	and    $0xfffffff0,%ecx
80108124:	83 c9 09             	or     $0x9,%ecx
80108127:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010812d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108134:	83 c9 10             	or     $0x10,%ecx
80108137:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010813d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108144:	83 e1 9f             	and    $0xffffff9f,%ecx
80108147:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010814d:	0f b6 88 a5 00 00 00 	movzbl 0xa5(%eax),%ecx
80108154:	83 c9 80             	or     $0xffffff80,%ecx
80108157:	88 88 a5 00 00 00    	mov    %cl,0xa5(%eax)
8010815d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108164:	83 e1 f0             	and    $0xfffffff0,%ecx
80108167:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010816d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108174:	83 e1 ef             	and    $0xffffffef,%ecx
80108177:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010817d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108184:	83 e1 df             	and    $0xffffffdf,%ecx
80108187:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010818d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
80108194:	83 c9 40             	or     $0x40,%ecx
80108197:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
8010819d:	0f b6 88 a6 00 00 00 	movzbl 0xa6(%eax),%ecx
801081a4:	83 e1 7f             	and    $0x7f,%ecx
801081a7:	88 88 a6 00 00 00    	mov    %cl,0xa6(%eax)
801081ad:	88 90 a7 00 00 00    	mov    %dl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801081b3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081b9:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801081c0:	83 e2 ef             	and    $0xffffffef,%edx
801081c3:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801081c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081cf:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801081d5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801081db:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801081e2:	8b 52 08             	mov    0x8(%edx),%edx
801081e5:	81 c2 00 10 00 00    	add    $0x1000,%edx
801081eb:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
801081ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
801081f5:	e8 df f7 ff ff       	call   801079d9 <ltr>
  if(p->pgdir == 0)
801081fa:	8b 45 08             	mov    0x8(%ebp),%eax
801081fd:	8b 40 04             	mov    0x4(%eax),%eax
80108200:	85 c0                	test   %eax,%eax
80108202:	75 0c                	jne    80108210 <switchuvm+0x146>
    panic("switchuvm: no pgdir");
80108204:	c7 04 24 f7 8d 10 80 	movl   $0x80108df7,(%esp)
8010820b:	e8 2a 83 ff ff       	call   8010053a <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108210:	8b 45 08             	mov    0x8(%ebp),%eax
80108213:	8b 40 04             	mov    0x4(%eax),%eax
80108216:	89 04 24             	mov    %eax,(%esp)
80108219:	e8 f1 f7 ff ff       	call   80107a0f <v2p>
8010821e:	89 04 24             	mov    %eax,(%esp)
80108221:	e8 de f7 ff ff       	call   80107a04 <lcr3>
  popcli();
80108226:	e8 8a cf ff ff       	call   801051b5 <popcli>
}
8010822b:	83 c4 14             	add    $0x14,%esp
8010822e:	5b                   	pop    %ebx
8010822f:	5d                   	pop    %ebp
80108230:	c3                   	ret    

80108231 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108231:	55                   	push   %ebp
80108232:	89 e5                	mov    %esp,%ebp
80108234:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108237:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010823e:	76 0c                	jbe    8010824c <inituvm+0x1b>
    panic("inituvm: more than a page");
80108240:	c7 04 24 0b 8e 10 80 	movl   $0x80108e0b,(%esp)
80108247:	e8 ee 82 ff ff       	call   8010053a <panic>
  mem = kalloc();
8010824c:	e8 f1 a9 ff ff       	call   80102c42 <kalloc>
80108251:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108254:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010825b:	00 
8010825c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108263:	00 
80108264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108267:	89 04 24             	mov    %eax,(%esp)
8010826a:	e8 02 d0 ff ff       	call   80105271 <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010826f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108272:	89 04 24             	mov    %eax,(%esp)
80108275:	e8 95 f7 ff ff       	call   80107a0f <v2p>
8010827a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108281:	00 
80108282:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108286:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010828d:	00 
8010828e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108295:	00 
80108296:	8b 45 08             	mov    0x8(%ebp),%eax
80108299:	89 04 24             	mov    %eax,(%esp)
8010829c:	e8 a0 fc ff ff       	call   80107f41 <mappages>
  memmove(mem, init, sz);
801082a1:	8b 45 10             	mov    0x10(%ebp),%eax
801082a4:	89 44 24 08          	mov    %eax,0x8(%esp)
801082a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801082ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801082af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b2:	89 04 24             	mov    %eax,(%esp)
801082b5:	e8 86 d0 ff ff       	call   80105340 <memmove>
}
801082ba:	c9                   	leave  
801082bb:	c3                   	ret    

801082bc <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801082bc:	55                   	push   %ebp
801082bd:	89 e5                	mov    %esp,%ebp
801082bf:	53                   	push   %ebx
801082c0:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801082c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801082c6:	25 ff 0f 00 00       	and    $0xfff,%eax
801082cb:	85 c0                	test   %eax,%eax
801082cd:	74 0c                	je     801082db <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
801082cf:	c7 04 24 28 8e 10 80 	movl   $0x80108e28,(%esp)
801082d6:	e8 5f 82 ff ff       	call   8010053a <panic>
  for(i = 0; i < sz; i += PGSIZE){
801082db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082e2:	e9 a9 00 00 00       	jmp    80108390 <loaduvm+0xd4>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801082e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ea:	8b 55 0c             	mov    0xc(%ebp),%edx
801082ed:	01 d0                	add    %edx,%eax
801082ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801082f6:	00 
801082f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801082fb:	8b 45 08             	mov    0x8(%ebp),%eax
801082fe:	89 04 24             	mov    %eax,(%esp)
80108301:	e8 99 fb ff ff       	call   80107e9f <walkpgdir>
80108306:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108309:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010830d:	75 0c                	jne    8010831b <loaduvm+0x5f>
      panic("loaduvm: address should exist");
8010830f:	c7 04 24 4b 8e 10 80 	movl   $0x80108e4b,(%esp)
80108316:	e8 1f 82 ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010831b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010831e:	8b 00                	mov    (%eax),%eax
80108320:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108325:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832b:	8b 55 18             	mov    0x18(%ebp),%edx
8010832e:	29 c2                	sub    %eax,%edx
80108330:	89 d0                	mov    %edx,%eax
80108332:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108337:	77 0f                	ja     80108348 <loaduvm+0x8c>
      n = sz - i;
80108339:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833c:	8b 55 18             	mov    0x18(%ebp),%edx
8010833f:	29 c2                	sub    %eax,%edx
80108341:	89 d0                	mov    %edx,%eax
80108343:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108346:	eb 07                	jmp    8010834f <loaduvm+0x93>
    else
      n = PGSIZE;
80108348:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010834f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108352:	8b 55 14             	mov    0x14(%ebp),%edx
80108355:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108358:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010835b:	89 04 24             	mov    %eax,(%esp)
8010835e:	e8 b9 f6 ff ff       	call   80107a1c <p2v>
80108363:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108366:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010836a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010836e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108372:	8b 45 10             	mov    0x10(%ebp),%eax
80108375:	89 04 24             	mov    %eax,(%esp)
80108378:	e8 4b 9b ff ff       	call   80101ec8 <readi>
8010837d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108380:	74 07                	je     80108389 <loaduvm+0xcd>
      return -1;
80108382:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108387:	eb 18                	jmp    801083a1 <loaduvm+0xe5>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108389:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108390:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108393:	3b 45 18             	cmp    0x18(%ebp),%eax
80108396:	0f 82 4b ff ff ff    	jb     801082e7 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010839c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801083a1:	83 c4 24             	add    $0x24,%esp
801083a4:	5b                   	pop    %ebx
801083a5:	5d                   	pop    %ebp
801083a6:	c3                   	ret    

801083a7 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083a7:	55                   	push   %ebp
801083a8:	89 e5                	mov    %esp,%ebp
801083aa:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801083ad:	8b 45 10             	mov    0x10(%ebp),%eax
801083b0:	85 c0                	test   %eax,%eax
801083b2:	79 0a                	jns    801083be <allocuvm+0x17>
    return 0;
801083b4:	b8 00 00 00 00       	mov    $0x0,%eax
801083b9:	e9 c1 00 00 00       	jmp    8010847f <allocuvm+0xd8>
  if(newsz < oldsz)
801083be:	8b 45 10             	mov    0x10(%ebp),%eax
801083c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083c4:	73 08                	jae    801083ce <allocuvm+0x27>
    return oldsz;
801083c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c9:	e9 b1 00 00 00       	jmp    8010847f <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
801083ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d1:	05 ff 0f 00 00       	add    $0xfff,%eax
801083d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801083de:	e9 8d 00 00 00       	jmp    80108470 <allocuvm+0xc9>
    mem = kalloc();
801083e3:	e8 5a a8 ff ff       	call   80102c42 <kalloc>
801083e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801083eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083ef:	75 2c                	jne    8010841d <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
801083f1:	c7 04 24 69 8e 10 80 	movl   $0x80108e69,(%esp)
801083f8:	e8 a3 7f ff ff       	call   801003a0 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801083fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108400:	89 44 24 08          	mov    %eax,0x8(%esp)
80108404:	8b 45 10             	mov    0x10(%ebp),%eax
80108407:	89 44 24 04          	mov    %eax,0x4(%esp)
8010840b:	8b 45 08             	mov    0x8(%ebp),%eax
8010840e:	89 04 24             	mov    %eax,(%esp)
80108411:	e8 6b 00 00 00       	call   80108481 <deallocuvm>
      return 0;
80108416:	b8 00 00 00 00       	mov    $0x0,%eax
8010841b:	eb 62                	jmp    8010847f <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
8010841d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108424:	00 
80108425:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010842c:	00 
8010842d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108430:	89 04 24             	mov    %eax,(%esp)
80108433:	e8 39 ce ff ff       	call   80105271 <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108438:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010843b:	89 04 24             	mov    %eax,(%esp)
8010843e:	e8 cc f5 ff ff       	call   80107a0f <v2p>
80108443:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108446:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010844d:	00 
8010844e:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108452:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108459:	00 
8010845a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010845e:	8b 45 08             	mov    0x8(%ebp),%eax
80108461:	89 04 24             	mov    %eax,(%esp)
80108464:	e8 d8 fa ff ff       	call   80107f41 <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108469:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108470:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108473:	3b 45 10             	cmp    0x10(%ebp),%eax
80108476:	0f 82 67 ff ff ff    	jb     801083e3 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010847c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010847f:	c9                   	leave  
80108480:	c3                   	ret    

80108481 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108481:	55                   	push   %ebp
80108482:	89 e5                	mov    %esp,%ebp
80108484:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108487:	8b 45 10             	mov    0x10(%ebp),%eax
8010848a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010848d:	72 08                	jb     80108497 <deallocuvm+0x16>
    return oldsz;
8010848f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108492:	e9 a4 00 00 00       	jmp    8010853b <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80108497:	8b 45 10             	mov    0x10(%ebp),%eax
8010849a:	05 ff 0f 00 00       	add    $0xfff,%eax
8010849f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801084a7:	e9 80 00 00 00       	jmp    8010852c <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
801084ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084b6:	00 
801084b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801084bb:	8b 45 08             	mov    0x8(%ebp),%eax
801084be:	89 04 24             	mov    %eax,(%esp)
801084c1:	e8 d9 f9 ff ff       	call   80107e9f <walkpgdir>
801084c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801084c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801084cd:	75 09                	jne    801084d8 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
801084cf:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801084d6:	eb 4d                	jmp    80108525 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
801084d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084db:	8b 00                	mov    (%eax),%eax
801084dd:	83 e0 01             	and    $0x1,%eax
801084e0:	85 c0                	test   %eax,%eax
801084e2:	74 41                	je     80108525 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
801084e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084e7:	8b 00                	mov    (%eax),%eax
801084e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801084f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801084f5:	75 0c                	jne    80108503 <deallocuvm+0x82>
        panic("kfree");
801084f7:	c7 04 24 81 8e 10 80 	movl   $0x80108e81,(%esp)
801084fe:	e8 37 80 ff ff       	call   8010053a <panic>
      char *v = p2v(pa);
80108503:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108506:	89 04 24             	mov    %eax,(%esp)
80108509:	e8 0e f5 ff ff       	call   80107a1c <p2v>
8010850e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108511:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108514:	89 04 24             	mov    %eax,(%esp)
80108517:	e8 8d a6 ff ff       	call   80102ba9 <kfree>
      *pte = 0;
8010851c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010851f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108525:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010852c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108532:	0f 82 74 ff ff ff    	jb     801084ac <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108538:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010853b:	c9                   	leave  
8010853c:	c3                   	ret    

8010853d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010853d:	55                   	push   %ebp
8010853e:	89 e5                	mov    %esp,%ebp
80108540:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108543:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108547:	75 0c                	jne    80108555 <freevm+0x18>
    panic("freevm: no pgdir");
80108549:	c7 04 24 87 8e 10 80 	movl   $0x80108e87,(%esp)
80108550:	e8 e5 7f ff ff       	call   8010053a <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108555:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010855c:	00 
8010855d:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108564:	80 
80108565:	8b 45 08             	mov    0x8(%ebp),%eax
80108568:	89 04 24             	mov    %eax,(%esp)
8010856b:	e8 11 ff ff ff       	call   80108481 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108570:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108577:	eb 48                	jmp    801085c1 <freevm+0x84>
    if(pgdir[i] & PTE_P){
80108579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010857c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108583:	8b 45 08             	mov    0x8(%ebp),%eax
80108586:	01 d0                	add    %edx,%eax
80108588:	8b 00                	mov    (%eax),%eax
8010858a:	83 e0 01             	and    $0x1,%eax
8010858d:	85 c0                	test   %eax,%eax
8010858f:	74 2c                	je     801085bd <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108594:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010859b:	8b 45 08             	mov    0x8(%ebp),%eax
8010859e:	01 d0                	add    %edx,%eax
801085a0:	8b 00                	mov    (%eax),%eax
801085a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a7:	89 04 24             	mov    %eax,(%esp)
801085aa:	e8 6d f4 ff ff       	call   80107a1c <p2v>
801085af:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801085b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b5:	89 04 24             	mov    %eax,(%esp)
801085b8:	e8 ec a5 ff ff       	call   80102ba9 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801085bd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801085c1:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801085c8:	76 af                	jbe    80108579 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801085ca:	8b 45 08             	mov    0x8(%ebp),%eax
801085cd:	89 04 24             	mov    %eax,(%esp)
801085d0:	e8 d4 a5 ff ff       	call   80102ba9 <kfree>
}
801085d5:	c9                   	leave  
801085d6:	c3                   	ret    

801085d7 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801085d7:	55                   	push   %ebp
801085d8:	89 e5                	mov    %esp,%ebp
801085da:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801085dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085e4:	00 
801085e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801085e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801085ec:	8b 45 08             	mov    0x8(%ebp),%eax
801085ef:	89 04 24             	mov    %eax,(%esp)
801085f2:	e8 a8 f8 ff ff       	call   80107e9f <walkpgdir>
801085f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801085fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085fe:	75 0c                	jne    8010860c <clearpteu+0x35>
    panic("clearpteu");
80108600:	c7 04 24 98 8e 10 80 	movl   $0x80108e98,(%esp)
80108607:	e8 2e 7f ff ff       	call   8010053a <panic>
  *pte &= ~PTE_U;
8010860c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860f:	8b 00                	mov    (%eax),%eax
80108611:	83 e0 fb             	and    $0xfffffffb,%eax
80108614:	89 c2                	mov    %eax,%edx
80108616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108619:	89 10                	mov    %edx,(%eax)
}
8010861b:	c9                   	leave  
8010861c:	c3                   	ret    

8010861d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010861d:	55                   	push   %ebp
8010861e:	89 e5                	mov    %esp,%ebp
80108620:	53                   	push   %ebx
80108621:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108624:	e8 b0 f9 ff ff       	call   80107fd9 <setupkvm>
80108629:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010862c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108630:	75 0a                	jne    8010863c <copyuvm+0x1f>
    return 0;
80108632:	b8 00 00 00 00       	mov    $0x0,%eax
80108637:	e9 fd 00 00 00       	jmp    80108739 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
8010863c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108643:	e9 d0 00 00 00       	jmp    80108718 <copyuvm+0xfb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108648:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108652:	00 
80108653:	89 44 24 04          	mov    %eax,0x4(%esp)
80108657:	8b 45 08             	mov    0x8(%ebp),%eax
8010865a:	89 04 24             	mov    %eax,(%esp)
8010865d:	e8 3d f8 ff ff       	call   80107e9f <walkpgdir>
80108662:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108665:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108669:	75 0c                	jne    80108677 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
8010866b:	c7 04 24 a2 8e 10 80 	movl   $0x80108ea2,(%esp)
80108672:	e8 c3 7e ff ff       	call   8010053a <panic>
    if(!(*pte & PTE_P))
80108677:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010867a:	8b 00                	mov    (%eax),%eax
8010867c:	83 e0 01             	and    $0x1,%eax
8010867f:	85 c0                	test   %eax,%eax
80108681:	75 0c                	jne    8010868f <copyuvm+0x72>
      panic("copyuvm: page not present");
80108683:	c7 04 24 bc 8e 10 80 	movl   $0x80108ebc,(%esp)
8010868a:	e8 ab 7e ff ff       	call   8010053a <panic>
    pa = PTE_ADDR(*pte);
8010868f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108692:	8b 00                	mov    (%eax),%eax
80108694:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108699:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010869c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010869f:	8b 00                	mov    (%eax),%eax
801086a1:	25 ff 0f 00 00       	and    $0xfff,%eax
801086a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801086a9:	e8 94 a5 ff ff       	call   80102c42 <kalloc>
801086ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
801086b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801086b5:	75 02                	jne    801086b9 <copyuvm+0x9c>
      goto bad;
801086b7:	eb 70                	jmp    80108729 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
801086b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801086bc:	89 04 24             	mov    %eax,(%esp)
801086bf:	e8 58 f3 ff ff       	call   80107a1c <p2v>
801086c4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086cb:	00 
801086cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801086d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086d3:	89 04 24             	mov    %eax,(%esp)
801086d6:	e8 65 cc ff ff       	call   80105340 <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801086db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801086de:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086e1:	89 04 24             	mov    %eax,(%esp)
801086e4:	e8 26 f3 ff ff       	call   80107a0f <v2p>
801086e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801086ec:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801086f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
801086f4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086fb:	00 
801086fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80108700:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108703:	89 04 24             	mov    %eax,(%esp)
80108706:	e8 36 f8 ff ff       	call   80107f41 <mappages>
8010870b:	85 c0                	test   %eax,%eax
8010870d:	79 02                	jns    80108711 <copyuvm+0xf4>
      goto bad;
8010870f:	eb 18                	jmp    80108729 <copyuvm+0x10c>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108711:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010871e:	0f 82 24 ff ff ff    	jb     80108648 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108724:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108727:	eb 10                	jmp    80108739 <copyuvm+0x11c>

bad:
  freevm(d);
80108729:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010872c:	89 04 24             	mov    %eax,(%esp)
8010872f:	e8 09 fe ff ff       	call   8010853d <freevm>
  return 0;
80108734:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108739:	83 c4 44             	add    $0x44,%esp
8010873c:	5b                   	pop    %ebx
8010873d:	5d                   	pop    %ebp
8010873e:	c3                   	ret    

8010873f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010873f:	55                   	push   %ebp
80108740:	89 e5                	mov    %esp,%ebp
80108742:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108745:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010874c:	00 
8010874d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108750:	89 44 24 04          	mov    %eax,0x4(%esp)
80108754:	8b 45 08             	mov    0x8(%ebp),%eax
80108757:	89 04 24             	mov    %eax,(%esp)
8010875a:	e8 40 f7 ff ff       	call   80107e9f <walkpgdir>
8010875f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108765:	8b 00                	mov    (%eax),%eax
80108767:	83 e0 01             	and    $0x1,%eax
8010876a:	85 c0                	test   %eax,%eax
8010876c:	75 07                	jne    80108775 <uva2ka+0x36>
    return 0;
8010876e:	b8 00 00 00 00       	mov    $0x0,%eax
80108773:	eb 25                	jmp    8010879a <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
80108775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108778:	8b 00                	mov    (%eax),%eax
8010877a:	83 e0 04             	and    $0x4,%eax
8010877d:	85 c0                	test   %eax,%eax
8010877f:	75 07                	jne    80108788 <uva2ka+0x49>
    return 0;
80108781:	b8 00 00 00 00       	mov    $0x0,%eax
80108786:	eb 12                	jmp    8010879a <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
80108788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878b:	8b 00                	mov    (%eax),%eax
8010878d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108792:	89 04 24             	mov    %eax,(%esp)
80108795:	e8 82 f2 ff ff       	call   80107a1c <p2v>
}
8010879a:	c9                   	leave  
8010879b:	c3                   	ret    

8010879c <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010879c:	55                   	push   %ebp
8010879d:	89 e5                	mov    %esp,%ebp
8010879f:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801087a2:	8b 45 10             	mov    0x10(%ebp),%eax
801087a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801087a8:	e9 87 00 00 00       	jmp    80108834 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801087ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801087b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801087b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801087bf:	8b 45 08             	mov    0x8(%ebp),%eax
801087c2:	89 04 24             	mov    %eax,(%esp)
801087c5:	e8 75 ff ff ff       	call   8010873f <uva2ka>
801087ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801087cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801087d1:	75 07                	jne    801087da <copyout+0x3e>
      return -1;
801087d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801087d8:	eb 69                	jmp    80108843 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801087da:	8b 45 0c             	mov    0xc(%ebp),%eax
801087dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801087e0:	29 c2                	sub    %eax,%edx
801087e2:	89 d0                	mov    %edx,%eax
801087e4:	05 00 10 00 00       	add    $0x1000,%eax
801087e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801087ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ef:	3b 45 14             	cmp    0x14(%ebp),%eax
801087f2:	76 06                	jbe    801087fa <copyout+0x5e>
      n = len;
801087f4:	8b 45 14             	mov    0x14(%ebp),%eax
801087f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801087fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80108800:	29 c2                	sub    %eax,%edx
80108802:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108805:	01 c2                	add    %eax,%edx
80108807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010880a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010880e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108811:	89 44 24 04          	mov    %eax,0x4(%esp)
80108815:	89 14 24             	mov    %edx,(%esp)
80108818:	e8 23 cb ff ff       	call   80105340 <memmove>
    len -= n;
8010881d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108820:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108826:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108829:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010882c:	05 00 10 00 00       	add    $0x1000,%eax
80108831:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108834:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108838:	0f 85 6f ff ff ff    	jne    801087ad <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010883e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108843:	c9                   	leave  
80108844:	c3                   	ret    
