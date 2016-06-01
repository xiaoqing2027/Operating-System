
_bigtest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  char buf[512];
  int fd, i, sectors;

  fd = open("big.file", O_CREATE | O_WRONLY);
   c:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  13:	00 
  14:	c7 04 24 04 0a 00 00 	movl   $0xa04,(%esp)
  1b:	e8 98 04 00 00       	call   4b8 <open>
  20:	89 84 24 24 02 00 00 	mov    %eax,0x224(%esp)
  if(fd < 0){
  27:	83 bc 24 24 02 00 00 	cmpl   $0x0,0x224(%esp)
  2e:	00 
  2f:	79 19                	jns    4a <main+0x4a>
    printf(2, "big: cannot open big.file for writing\n");
  31:	c7 44 24 04 10 0a 00 	movl   $0xa10,0x4(%esp)
  38:	00 
  39:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  40:	e8 f3 05 00 00       	call   638 <printf>
    exit();
  45:	e8 2e 04 00 00       	call   478 <exit>
  }

  sectors = 0;
  4a:	c7 84 24 28 02 00 00 	movl   $0x0,0x228(%esp)
  51:	00 00 00 00 
  while(1){
    *(int*)buf = sectors;
  55:	8d 44 24 1c          	lea    0x1c(%esp),%eax
  59:	8b 94 24 28 02 00 00 	mov    0x228(%esp),%edx
  60:	89 10                	mov    %edx,(%eax)
    int cc = write(fd, buf, sizeof(buf));
  62:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  69:	00 
  6a:	8d 44 24 1c          	lea    0x1c(%esp),%eax
  6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  72:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
  79:	89 04 24             	mov    %eax,(%esp)
  7c:	e8 17 04 00 00       	call   498 <write>
  81:	89 84 24 20 02 00 00 	mov    %eax,0x220(%esp)
    if(cc <= 0)
  88:	83 bc 24 20 02 00 00 	cmpl   $0x0,0x220(%esp)
  8f:	00 
  90:	7f 56                	jg     e8 <main+0xe8>
      break;
  92:	90                   	nop
    sectors++;
	if (sectors % 100 == 0)
		printf(2, ".");
  }

  printf(1, "\nwrote %d sectors\n", sectors);
  93:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
  9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  9e:	c7 44 24 04 39 0a 00 	movl   $0xa39,0x4(%esp)
  a5:	00 
  a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ad:	e8 86 05 00 00       	call   638 <printf>

  close(fd);
  b2:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
  b9:	89 04 24             	mov    %eax,(%esp)
  bc:	e8 df 03 00 00       	call   4a0 <close>
  fd = open("big.file", O_RDONLY);
  c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 04 0a 00 00 	movl   $0xa04,(%esp)
  d0:	e8 e3 03 00 00       	call   4b8 <open>
  d5:	89 84 24 24 02 00 00 	mov    %eax,0x224(%esp)
  if(fd < 0){
  dc:	83 bc 24 24 02 00 00 	cmpl   $0x0,0x224(%esp)
  e3:	00 
  e4:	79 68                	jns    14e <main+0x14e>
  e6:	eb 4d                	jmp    135 <main+0x135>
  while(1){
    *(int*)buf = sectors;
    int cc = write(fd, buf, sizeof(buf));
    if(cc <= 0)
      break;
    sectors++;
  e8:	83 84 24 28 02 00 00 	addl   $0x1,0x228(%esp)
  ef:	01 
	if (sectors % 100 == 0)
  f0:	8b 8c 24 28 02 00 00 	mov    0x228(%esp),%ecx
  f7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  fc:	89 c8                	mov    %ecx,%eax
  fe:	f7 ea                	imul   %edx
 100:	c1 fa 05             	sar    $0x5,%edx
 103:	89 c8                	mov    %ecx,%eax
 105:	c1 f8 1f             	sar    $0x1f,%eax
 108:	29 c2                	sub    %eax,%edx
 10a:	89 d0                	mov    %edx,%eax
 10c:	6b c0 64             	imul   $0x64,%eax,%eax
 10f:	29 c1                	sub    %eax,%ecx
 111:	89 c8                	mov    %ecx,%eax
 113:	85 c0                	test   %eax,%eax
 115:	75 19                	jne    130 <main+0x130>
		printf(2, ".");
 117:	c7 44 24 04 37 0a 00 	movl   $0xa37,0x4(%esp)
 11e:	00 
 11f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 126:	e8 0d 05 00 00       	call   638 <printf>
  }
 12b:	e9 25 ff ff ff       	jmp    55 <main+0x55>
 130:	e9 20 ff ff ff       	jmp    55 <main+0x55>
  printf(1, "\nwrote %d sectors\n", sectors);

  close(fd);
  fd = open("big.file", O_RDONLY);
  if(fd < 0){
    printf(2, "big: cannot re-open big.file for reading\n");
 135:	c7 44 24 04 4c 0a 00 	movl   $0xa4c,0x4(%esp)
 13c:	00 
 13d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 144:	e8 ef 04 00 00       	call   638 <printf>
    exit();
 149:	e8 2a 03 00 00       	call   478 <exit>
  }
  for(i = 0; i < sectors; i++){
 14e:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 155:	00 00 00 00 
 159:	e9 99 00 00 00       	jmp    1f7 <main+0x1f7>
    int cc = read(fd, buf, sizeof(buf));
 15e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 165:	00 
 166:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 16a:	89 44 24 04          	mov    %eax,0x4(%esp)
 16e:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
 175:	89 04 24             	mov    %eax,(%esp)
 178:	e8 13 03 00 00       	call   490 <read>
 17d:	89 84 24 1c 02 00 00 	mov    %eax,0x21c(%esp)
    if(cc <= 0){
 184:	83 bc 24 1c 02 00 00 	cmpl   $0x0,0x21c(%esp)
 18b:	00 
 18c:	7f 24                	jg     1b2 <main+0x1b2>
      printf(2, "big: read error at sector %d\n", i);
 18e:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
 195:	89 44 24 08          	mov    %eax,0x8(%esp)
 199:	c7 44 24 04 76 0a 00 	movl   $0xa76,0x4(%esp)
 1a0:	00 
 1a1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1a8:	e8 8b 04 00 00       	call   638 <printf>
      exit();
 1ad:	e8 c6 02 00 00       	call   478 <exit>
    }
    if(*(int*)buf != i){
 1b2:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 1b6:	8b 00                	mov    (%eax),%eax
 1b8:	3b 84 24 2c 02 00 00 	cmp    0x22c(%esp),%eax
 1bf:	74 2e                	je     1ef <main+0x1ef>
      printf(2, "big: read the wrong data (%d) for sector %d\n",
             *(int*)buf, i);
 1c1:	8d 44 24 1c          	lea    0x1c(%esp),%eax
    if(cc <= 0){
      printf(2, "big: read error at sector %d\n", i);
      exit();
    }
    if(*(int*)buf != i){
      printf(2, "big: read the wrong data (%d) for sector %d\n",
 1c5:	8b 00                	mov    (%eax),%eax
 1c7:	8b 94 24 2c 02 00 00 	mov    0x22c(%esp),%edx
 1ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
 1d2:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d6:	c7 44 24 04 94 0a 00 	movl   $0xa94,0x4(%esp)
 1dd:	00 
 1de:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1e5:	e8 4e 04 00 00       	call   638 <printf>
             *(int*)buf, i);
      exit();
 1ea:	e8 89 02 00 00       	call   478 <exit>
  fd = open("big.file", O_RDONLY);
  if(fd < 0){
    printf(2, "big: cannot re-open big.file for reading\n");
    exit();
  }
  for(i = 0; i < sectors; i++){
 1ef:	83 84 24 2c 02 00 00 	addl   $0x1,0x22c(%esp)
 1f6:	01 
 1f7:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
 1fe:	3b 84 24 28 02 00 00 	cmp    0x228(%esp),%eax
 205:	0f 8c 53 ff ff ff    	jl     15e <main+0x15e>
             *(int*)buf, i);
      exit();
    }
  }

  exit();
 20b:	e8 68 02 00 00       	call   478 <exit>

00000210 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 210:	55                   	push   %ebp
 211:	89 e5                	mov    %esp,%ebp
 213:	57                   	push   %edi
 214:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 215:	8b 4d 08             	mov    0x8(%ebp),%ecx
 218:	8b 55 10             	mov    0x10(%ebp),%edx
 21b:	8b 45 0c             	mov    0xc(%ebp),%eax
 21e:	89 cb                	mov    %ecx,%ebx
 220:	89 df                	mov    %ebx,%edi
 222:	89 d1                	mov    %edx,%ecx
 224:	fc                   	cld    
 225:	f3 aa                	rep stos %al,%es:(%edi)
 227:	89 ca                	mov    %ecx,%edx
 229:	89 fb                	mov    %edi,%ebx
 22b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 22e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 231:	5b                   	pop    %ebx
 232:	5f                   	pop    %edi
 233:	5d                   	pop    %ebp
 234:	c3                   	ret    

00000235 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 235:	55                   	push   %ebp
 236:	89 e5                	mov    %esp,%ebp
 238:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 23b:	8b 45 08             	mov    0x8(%ebp),%eax
 23e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 241:	90                   	nop
 242:	8b 45 08             	mov    0x8(%ebp),%eax
 245:	8d 50 01             	lea    0x1(%eax),%edx
 248:	89 55 08             	mov    %edx,0x8(%ebp)
 24b:	8b 55 0c             	mov    0xc(%ebp),%edx
 24e:	8d 4a 01             	lea    0x1(%edx),%ecx
 251:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 254:	0f b6 12             	movzbl (%edx),%edx
 257:	88 10                	mov    %dl,(%eax)
 259:	0f b6 00             	movzbl (%eax),%eax
 25c:	84 c0                	test   %al,%al
 25e:	75 e2                	jne    242 <strcpy+0xd>
    ;
  return os;
 260:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 263:	c9                   	leave  
 264:	c3                   	ret    

00000265 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 265:	55                   	push   %ebp
 266:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 268:	eb 08                	jmp    272 <strcmp+0xd>
    p++, q++;
 26a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 26e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	0f b6 00             	movzbl (%eax),%eax
 278:	84 c0                	test   %al,%al
 27a:	74 10                	je     28c <strcmp+0x27>
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	0f b6 10             	movzbl (%eax),%edx
 282:	8b 45 0c             	mov    0xc(%ebp),%eax
 285:	0f b6 00             	movzbl (%eax),%eax
 288:	38 c2                	cmp    %al,%dl
 28a:	74 de                	je     26a <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	0f b6 00             	movzbl (%eax),%eax
 292:	0f b6 d0             	movzbl %al,%edx
 295:	8b 45 0c             	mov    0xc(%ebp),%eax
 298:	0f b6 00             	movzbl (%eax),%eax
 29b:	0f b6 c0             	movzbl %al,%eax
 29e:	29 c2                	sub    %eax,%edx
 2a0:	89 d0                	mov    %edx,%eax
}
 2a2:	5d                   	pop    %ebp
 2a3:	c3                   	ret    

000002a4 <strlen>:

uint
strlen(char *s)
{
 2a4:	55                   	push   %ebp
 2a5:	89 e5                	mov    %esp,%ebp
 2a7:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2b1:	eb 04                	jmp    2b7 <strlen+0x13>
 2b3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2b7:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2ba:	8b 45 08             	mov    0x8(%ebp),%eax
 2bd:	01 d0                	add    %edx,%eax
 2bf:	0f b6 00             	movzbl (%eax),%eax
 2c2:	84 c0                	test   %al,%al
 2c4:	75 ed                	jne    2b3 <strlen+0xf>
    ;
  return n;
 2c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2c9:	c9                   	leave  
 2ca:	c3                   	ret    

000002cb <memset>:

void*
memset(void *dst, int c, uint n)
{
 2cb:	55                   	push   %ebp
 2cc:	89 e5                	mov    %esp,%ebp
 2ce:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2d1:	8b 45 10             	mov    0x10(%ebp),%eax
 2d4:	89 44 24 08          	mov    %eax,0x8(%esp)
 2d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2db:	89 44 24 04          	mov    %eax,0x4(%esp)
 2df:	8b 45 08             	mov    0x8(%ebp),%eax
 2e2:	89 04 24             	mov    %eax,(%esp)
 2e5:	e8 26 ff ff ff       	call   210 <stosb>
  return dst;
 2ea:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ed:	c9                   	leave  
 2ee:	c3                   	ret    

000002ef <strchr>:

char*
strchr(const char *s, char c)
{
 2ef:	55                   	push   %ebp
 2f0:	89 e5                	mov    %esp,%ebp
 2f2:	83 ec 04             	sub    $0x4,%esp
 2f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2fb:	eb 14                	jmp    311 <strchr+0x22>
    if(*s == c)
 2fd:	8b 45 08             	mov    0x8(%ebp),%eax
 300:	0f b6 00             	movzbl (%eax),%eax
 303:	3a 45 fc             	cmp    -0x4(%ebp),%al
 306:	75 05                	jne    30d <strchr+0x1e>
      return (char*)s;
 308:	8b 45 08             	mov    0x8(%ebp),%eax
 30b:	eb 13                	jmp    320 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 30d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 311:	8b 45 08             	mov    0x8(%ebp),%eax
 314:	0f b6 00             	movzbl (%eax),%eax
 317:	84 c0                	test   %al,%al
 319:	75 e2                	jne    2fd <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 31b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 320:	c9                   	leave  
 321:	c3                   	ret    

00000322 <gets>:

char*
gets(char *buf, int max)
{
 322:	55                   	push   %ebp
 323:	89 e5                	mov    %esp,%ebp
 325:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 328:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 32f:	eb 4c                	jmp    37d <gets+0x5b>
    cc = read(0, &c, 1);
 331:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 338:	00 
 339:	8d 45 ef             	lea    -0x11(%ebp),%eax
 33c:	89 44 24 04          	mov    %eax,0x4(%esp)
 340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 347:	e8 44 01 00 00       	call   490 <read>
 34c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 34f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 353:	7f 02                	jg     357 <gets+0x35>
      break;
 355:	eb 31                	jmp    388 <gets+0x66>
    buf[i++] = c;
 357:	8b 45 f4             	mov    -0xc(%ebp),%eax
 35a:	8d 50 01             	lea    0x1(%eax),%edx
 35d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 360:	89 c2                	mov    %eax,%edx
 362:	8b 45 08             	mov    0x8(%ebp),%eax
 365:	01 c2                	add    %eax,%edx
 367:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 36b:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 36d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 371:	3c 0a                	cmp    $0xa,%al
 373:	74 13                	je     388 <gets+0x66>
 375:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 379:	3c 0d                	cmp    $0xd,%al
 37b:	74 0b                	je     388 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 37d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 380:	83 c0 01             	add    $0x1,%eax
 383:	3b 45 0c             	cmp    0xc(%ebp),%eax
 386:	7c a9                	jl     331 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 388:	8b 55 f4             	mov    -0xc(%ebp),%edx
 38b:	8b 45 08             	mov    0x8(%ebp),%eax
 38e:	01 d0                	add    %edx,%eax
 390:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 393:	8b 45 08             	mov    0x8(%ebp),%eax
}
 396:	c9                   	leave  
 397:	c3                   	ret    

00000398 <stat>:

int
stat(char *n, struct stat *st)
{
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
 39b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 39e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 3a5:	00 
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	89 04 24             	mov    %eax,(%esp)
 3ac:	e8 07 01 00 00       	call   4b8 <open>
 3b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3b8:	79 07                	jns    3c1 <stat+0x29>
    return -1;
 3ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3bf:	eb 23                	jmp    3e4 <stat+0x4c>
  r = fstat(fd, st);
 3c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 3c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3cb:	89 04 24             	mov    %eax,(%esp)
 3ce:	e8 fd 00 00 00       	call   4d0 <fstat>
 3d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d9:	89 04 24             	mov    %eax,(%esp)
 3dc:	e8 bf 00 00 00       	call   4a0 <close>
  return r;
 3e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3e4:	c9                   	leave  
 3e5:	c3                   	ret    

000003e6 <atoi>:

int
atoi(const char *s)
{
 3e6:	55                   	push   %ebp
 3e7:	89 e5                	mov    %esp,%ebp
 3e9:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3ec:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3f3:	eb 25                	jmp    41a <atoi+0x34>
    n = n*10 + *s++ - '0';
 3f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f8:	89 d0                	mov    %edx,%eax
 3fa:	c1 e0 02             	shl    $0x2,%eax
 3fd:	01 d0                	add    %edx,%eax
 3ff:	01 c0                	add    %eax,%eax
 401:	89 c1                	mov    %eax,%ecx
 403:	8b 45 08             	mov    0x8(%ebp),%eax
 406:	8d 50 01             	lea    0x1(%eax),%edx
 409:	89 55 08             	mov    %edx,0x8(%ebp)
 40c:	0f b6 00             	movzbl (%eax),%eax
 40f:	0f be c0             	movsbl %al,%eax
 412:	01 c8                	add    %ecx,%eax
 414:	83 e8 30             	sub    $0x30,%eax
 417:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 41a:	8b 45 08             	mov    0x8(%ebp),%eax
 41d:	0f b6 00             	movzbl (%eax),%eax
 420:	3c 2f                	cmp    $0x2f,%al
 422:	7e 0a                	jle    42e <atoi+0x48>
 424:	8b 45 08             	mov    0x8(%ebp),%eax
 427:	0f b6 00             	movzbl (%eax),%eax
 42a:	3c 39                	cmp    $0x39,%al
 42c:	7e c7                	jle    3f5 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 42e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 431:	c9                   	leave  
 432:	c3                   	ret    

00000433 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 433:	55                   	push   %ebp
 434:	89 e5                	mov    %esp,%ebp
 436:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 439:	8b 45 08             	mov    0x8(%ebp),%eax
 43c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 43f:	8b 45 0c             	mov    0xc(%ebp),%eax
 442:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 445:	eb 17                	jmp    45e <memmove+0x2b>
    *dst++ = *src++;
 447:	8b 45 fc             	mov    -0x4(%ebp),%eax
 44a:	8d 50 01             	lea    0x1(%eax),%edx
 44d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 450:	8b 55 f8             	mov    -0x8(%ebp),%edx
 453:	8d 4a 01             	lea    0x1(%edx),%ecx
 456:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 459:	0f b6 12             	movzbl (%edx),%edx
 45c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 45e:	8b 45 10             	mov    0x10(%ebp),%eax
 461:	8d 50 ff             	lea    -0x1(%eax),%edx
 464:	89 55 10             	mov    %edx,0x10(%ebp)
 467:	85 c0                	test   %eax,%eax
 469:	7f dc                	jg     447 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
}
 46e:	c9                   	leave  
 46f:	c3                   	ret    

00000470 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 470:	b8 01 00 00 00       	mov    $0x1,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <exit>:
SYSCALL(exit)
 478:	b8 02 00 00 00       	mov    $0x2,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <wait>:
SYSCALL(wait)
 480:	b8 03 00 00 00       	mov    $0x3,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <pipe>:
SYSCALL(pipe)
 488:	b8 04 00 00 00       	mov    $0x4,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <read>:
SYSCALL(read)
 490:	b8 05 00 00 00       	mov    $0x5,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <write>:
SYSCALL(write)
 498:	b8 10 00 00 00       	mov    $0x10,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <close>:
SYSCALL(close)
 4a0:	b8 15 00 00 00       	mov    $0x15,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <kill>:
SYSCALL(kill)
 4a8:	b8 06 00 00 00       	mov    $0x6,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <exec>:
SYSCALL(exec)
 4b0:	b8 07 00 00 00       	mov    $0x7,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <open>:
SYSCALL(open)
 4b8:	b8 0f 00 00 00       	mov    $0xf,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <mknod>:
SYSCALL(mknod)
 4c0:	b8 11 00 00 00       	mov    $0x11,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <unlink>:
SYSCALL(unlink)
 4c8:	b8 12 00 00 00       	mov    $0x12,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <fstat>:
SYSCALL(fstat)
 4d0:	b8 08 00 00 00       	mov    $0x8,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <link>:
SYSCALL(link)
 4d8:	b8 13 00 00 00       	mov    $0x13,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <mkdir>:
SYSCALL(mkdir)
 4e0:	b8 14 00 00 00       	mov    $0x14,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <chdir>:
SYSCALL(chdir)
 4e8:	b8 09 00 00 00       	mov    $0x9,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <dup>:
SYSCALL(dup)
 4f0:	b8 0a 00 00 00       	mov    $0xa,%eax
 4f5:	cd 40                	int    $0x40
 4f7:	c3                   	ret    

000004f8 <getpid>:
SYSCALL(getpid)
 4f8:	b8 0b 00 00 00       	mov    $0xb,%eax
 4fd:	cd 40                	int    $0x40
 4ff:	c3                   	ret    

00000500 <sbrk>:
SYSCALL(sbrk)
 500:	b8 0c 00 00 00       	mov    $0xc,%eax
 505:	cd 40                	int    $0x40
 507:	c3                   	ret    

00000508 <sleep>:
SYSCALL(sleep)
 508:	b8 0d 00 00 00       	mov    $0xd,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <uptime>:
SYSCALL(uptime)
 510:	b8 0e 00 00 00       	mov    $0xe,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <startBurst>:
SYSCALL(startBurst)
 518:	b8 16 00 00 00       	mov    $0x16,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <endBurst>:
SYSCALL(endBurst)
 520:	b8 17 00 00 00       	mov    $0x17,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <print_bursts>:
SYSCALL(print_bursts)
 528:	b8 18 00 00 00       	mov    $0x18,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <thread_create>:
SYSCALL(thread_create)
 530:	b8 19 00 00 00       	mov    $0x19,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <thread_join>:
SYSCALL(thread_join)
 538:	b8 1a 00 00 00       	mov    $0x1a,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <mtx_create>:
SYSCALL(mtx_create)
 540:	b8 1b 00 00 00       	mov    $0x1b,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <mtx_lock>:
SYSCALL(mtx_lock)
 548:	b8 1c 00 00 00       	mov    $0x1c,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <mtx_unlock>:
SYSCALL(mtx_unlock)
 550:	b8 1d 00 00 00       	mov    $0x1d,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 558:	55                   	push   %ebp
 559:	89 e5                	mov    %esp,%ebp
 55b:	83 ec 18             	sub    $0x18,%esp
 55e:	8b 45 0c             	mov    0xc(%ebp),%eax
 561:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 564:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 56b:	00 
 56c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 56f:	89 44 24 04          	mov    %eax,0x4(%esp)
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	89 04 24             	mov    %eax,(%esp)
 579:	e8 1a ff ff ff       	call   498 <write>
}
 57e:	c9                   	leave  
 57f:	c3                   	ret    

00000580 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 580:	55                   	push   %ebp
 581:	89 e5                	mov    %esp,%ebp
 583:	56                   	push   %esi
 584:	53                   	push   %ebx
 585:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 588:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 58f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 593:	74 17                	je     5ac <printint+0x2c>
 595:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 599:	79 11                	jns    5ac <printint+0x2c>
    neg = 1;
 59b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a5:	f7 d8                	neg    %eax
 5a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5aa:	eb 06                	jmp    5b2 <printint+0x32>
  } else {
    x = xx;
 5ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 5af:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5b9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 5bc:	8d 41 01             	lea    0x1(%ecx),%eax
 5bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
 5c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 5c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c8:	ba 00 00 00 00       	mov    $0x0,%edx
 5cd:	f7 f3                	div    %ebx
 5cf:	89 d0                	mov    %edx,%eax
 5d1:	0f b6 80 0c 0d 00 00 	movzbl 0xd0c(%eax),%eax
 5d8:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 5dc:	8b 75 10             	mov    0x10(%ebp),%esi
 5df:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5e2:	ba 00 00 00 00       	mov    $0x0,%edx
 5e7:	f7 f6                	div    %esi
 5e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5ec:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f0:	75 c7                	jne    5b9 <printint+0x39>
  if(neg)
 5f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5f6:	74 10                	je     608 <printint+0x88>
    buf[i++] = '-';
 5f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fb:	8d 50 01             	lea    0x1(%eax),%edx
 5fe:	89 55 f4             	mov    %edx,-0xc(%ebp)
 601:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 606:	eb 1f                	jmp    627 <printint+0xa7>
 608:	eb 1d                	jmp    627 <printint+0xa7>
    putc(fd, buf[i]);
 60a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 610:	01 d0                	add    %edx,%eax
 612:	0f b6 00             	movzbl (%eax),%eax
 615:	0f be c0             	movsbl %al,%eax
 618:	89 44 24 04          	mov    %eax,0x4(%esp)
 61c:	8b 45 08             	mov    0x8(%ebp),%eax
 61f:	89 04 24             	mov    %eax,(%esp)
 622:	e8 31 ff ff ff       	call   558 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 627:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 62b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 62f:	79 d9                	jns    60a <printint+0x8a>
    putc(fd, buf[i]);
}
 631:	83 c4 30             	add    $0x30,%esp
 634:	5b                   	pop    %ebx
 635:	5e                   	pop    %esi
 636:	5d                   	pop    %ebp
 637:	c3                   	ret    

00000638 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 638:	55                   	push   %ebp
 639:	89 e5                	mov    %esp,%ebp
 63b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 63e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 645:	8d 45 0c             	lea    0xc(%ebp),%eax
 648:	83 c0 04             	add    $0x4,%eax
 64b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 64e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 655:	e9 7c 01 00 00       	jmp    7d6 <printf+0x19e>
    c = fmt[i] & 0xff;
 65a:	8b 55 0c             	mov    0xc(%ebp),%edx
 65d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 660:	01 d0                	add    %edx,%eax
 662:	0f b6 00             	movzbl (%eax),%eax
 665:	0f be c0             	movsbl %al,%eax
 668:	25 ff 00 00 00       	and    $0xff,%eax
 66d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 670:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 674:	75 2c                	jne    6a2 <printf+0x6a>
      if(c == '%'){
 676:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67a:	75 0c                	jne    688 <printf+0x50>
        state = '%';
 67c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 683:	e9 4a 01 00 00       	jmp    7d2 <printf+0x19a>
      } else {
        putc(fd, c);
 688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68b:	0f be c0             	movsbl %al,%eax
 68e:	89 44 24 04          	mov    %eax,0x4(%esp)
 692:	8b 45 08             	mov    0x8(%ebp),%eax
 695:	89 04 24             	mov    %eax,(%esp)
 698:	e8 bb fe ff ff       	call   558 <putc>
 69d:	e9 30 01 00 00       	jmp    7d2 <printf+0x19a>
      }
    } else if(state == '%'){
 6a2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6a6:	0f 85 26 01 00 00    	jne    7d2 <printf+0x19a>
      if(c == 'd'){
 6ac:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6b0:	75 2d                	jne    6df <printf+0xa7>
        printint(fd, *ap, 10, 1);
 6b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 6be:	00 
 6bf:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 6c6:	00 
 6c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6cb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ce:	89 04 24             	mov    %eax,(%esp)
 6d1:	e8 aa fe ff ff       	call   580 <printint>
        ap++;
 6d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6da:	e9 ec 00 00 00       	jmp    7cb <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 6df:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6e3:	74 06                	je     6eb <printf+0xb3>
 6e5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6e9:	75 2d                	jne    718 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 6eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6ee:	8b 00                	mov    (%eax),%eax
 6f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 6f7:	00 
 6f8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 6ff:	00 
 700:	89 44 24 04          	mov    %eax,0x4(%esp)
 704:	8b 45 08             	mov    0x8(%ebp),%eax
 707:	89 04 24             	mov    %eax,(%esp)
 70a:	e8 71 fe ff ff       	call   580 <printint>
        ap++;
 70f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 713:	e9 b3 00 00 00       	jmp    7cb <printf+0x193>
      } else if(c == 's'){
 718:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 71c:	75 45                	jne    763 <printf+0x12b>
        s = (char*)*ap;
 71e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 721:	8b 00                	mov    (%eax),%eax
 723:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 726:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 72a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 72e:	75 09                	jne    739 <printf+0x101>
          s = "(null)";
 730:	c7 45 f4 c1 0a 00 00 	movl   $0xac1,-0xc(%ebp)
        while(*s != 0){
 737:	eb 1e                	jmp    757 <printf+0x11f>
 739:	eb 1c                	jmp    757 <printf+0x11f>
          putc(fd, *s);
 73b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73e:	0f b6 00             	movzbl (%eax),%eax
 741:	0f be c0             	movsbl %al,%eax
 744:	89 44 24 04          	mov    %eax,0x4(%esp)
 748:	8b 45 08             	mov    0x8(%ebp),%eax
 74b:	89 04 24             	mov    %eax,(%esp)
 74e:	e8 05 fe ff ff       	call   558 <putc>
          s++;
 753:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 757:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75a:	0f b6 00             	movzbl (%eax),%eax
 75d:	84 c0                	test   %al,%al
 75f:	75 da                	jne    73b <printf+0x103>
 761:	eb 68                	jmp    7cb <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 763:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 767:	75 1d                	jne    786 <printf+0x14e>
        putc(fd, *ap);
 769:	8b 45 e8             	mov    -0x18(%ebp),%eax
 76c:	8b 00                	mov    (%eax),%eax
 76e:	0f be c0             	movsbl %al,%eax
 771:	89 44 24 04          	mov    %eax,0x4(%esp)
 775:	8b 45 08             	mov    0x8(%ebp),%eax
 778:	89 04 24             	mov    %eax,(%esp)
 77b:	e8 d8 fd ff ff       	call   558 <putc>
        ap++;
 780:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 784:	eb 45                	jmp    7cb <printf+0x193>
      } else if(c == '%'){
 786:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78a:	75 17                	jne    7a3 <printf+0x16b>
        putc(fd, c);
 78c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 78f:	0f be c0             	movsbl %al,%eax
 792:	89 44 24 04          	mov    %eax,0x4(%esp)
 796:	8b 45 08             	mov    0x8(%ebp),%eax
 799:	89 04 24             	mov    %eax,(%esp)
 79c:	e8 b7 fd ff ff       	call   558 <putc>
 7a1:	eb 28                	jmp    7cb <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7a3:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 7aa:	00 
 7ab:	8b 45 08             	mov    0x8(%ebp),%eax
 7ae:	89 04 24             	mov    %eax,(%esp)
 7b1:	e8 a2 fd ff ff       	call   558 <putc>
        putc(fd, c);
 7b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7b9:	0f be c0             	movsbl %al,%eax
 7bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 7c0:	8b 45 08             	mov    0x8(%ebp),%eax
 7c3:	89 04 24             	mov    %eax,(%esp)
 7c6:	e8 8d fd ff ff       	call   558 <putc>
      }
      state = 0;
 7cb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 7d2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7d6:	8b 55 0c             	mov    0xc(%ebp),%edx
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	01 d0                	add    %edx,%eax
 7de:	0f b6 00             	movzbl (%eax),%eax
 7e1:	84 c0                	test   %al,%al
 7e3:	0f 85 71 fe ff ff    	jne    65a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 7e9:	c9                   	leave  
 7ea:	c3                   	ret    

000007eb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7eb:	55                   	push   %ebp
 7ec:	89 e5                	mov    %esp,%ebp
 7ee:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7f1:	8b 45 08             	mov    0x8(%ebp),%eax
 7f4:	83 e8 08             	sub    $0x8,%eax
 7f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fa:	a1 28 0d 00 00       	mov    0xd28,%eax
 7ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
 802:	eb 24                	jmp    828 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 804:	8b 45 fc             	mov    -0x4(%ebp),%eax
 807:	8b 00                	mov    (%eax),%eax
 809:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 80c:	77 12                	ja     820 <free+0x35>
 80e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 811:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 814:	77 24                	ja     83a <free+0x4f>
 816:	8b 45 fc             	mov    -0x4(%ebp),%eax
 819:	8b 00                	mov    (%eax),%eax
 81b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 81e:	77 1a                	ja     83a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	8b 00                	mov    (%eax),%eax
 825:	89 45 fc             	mov    %eax,-0x4(%ebp)
 828:	8b 45 f8             	mov    -0x8(%ebp),%eax
 82b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 82e:	76 d4                	jbe    804 <free+0x19>
 830:	8b 45 fc             	mov    -0x4(%ebp),%eax
 833:	8b 00                	mov    (%eax),%eax
 835:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 838:	76 ca                	jbe    804 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 83a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83d:	8b 40 04             	mov    0x4(%eax),%eax
 840:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 847:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84a:	01 c2                	add    %eax,%edx
 84c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84f:	8b 00                	mov    (%eax),%eax
 851:	39 c2                	cmp    %eax,%edx
 853:	75 24                	jne    879 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 855:	8b 45 f8             	mov    -0x8(%ebp),%eax
 858:	8b 50 04             	mov    0x4(%eax),%edx
 85b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85e:	8b 00                	mov    (%eax),%eax
 860:	8b 40 04             	mov    0x4(%eax),%eax
 863:	01 c2                	add    %eax,%edx
 865:	8b 45 f8             	mov    -0x8(%ebp),%eax
 868:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 86b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86e:	8b 00                	mov    (%eax),%eax
 870:	8b 10                	mov    (%eax),%edx
 872:	8b 45 f8             	mov    -0x8(%ebp),%eax
 875:	89 10                	mov    %edx,(%eax)
 877:	eb 0a                	jmp    883 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 10                	mov    (%eax),%edx
 87e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 881:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 883:	8b 45 fc             	mov    -0x4(%ebp),%eax
 886:	8b 40 04             	mov    0x4(%eax),%eax
 889:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 890:	8b 45 fc             	mov    -0x4(%ebp),%eax
 893:	01 d0                	add    %edx,%eax
 895:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 898:	75 20                	jne    8ba <free+0xcf>
    p->s.size += bp->s.size;
 89a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89d:	8b 50 04             	mov    0x4(%eax),%edx
 8a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8a3:	8b 40 04             	mov    0x4(%eax),%eax
 8a6:	01 c2                	add    %eax,%edx
 8a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8ab:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 8ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b1:	8b 10                	mov    (%eax),%edx
 8b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b6:	89 10                	mov    %edx,(%eax)
 8b8:	eb 08                	jmp    8c2 <free+0xd7>
  } else
    p->s.ptr = bp;
 8ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8bd:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8c0:	89 10                	mov    %edx,(%eax)
  freep = p;
 8c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c5:	a3 28 0d 00 00       	mov    %eax,0xd28
}
 8ca:	c9                   	leave  
 8cb:	c3                   	ret    

000008cc <morecore>:

static Header*
morecore(uint nu)
{
 8cc:	55                   	push   %ebp
 8cd:	89 e5                	mov    %esp,%ebp
 8cf:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8d2:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8d9:	77 07                	ja     8e2 <morecore+0x16>
    nu = 4096;
 8db:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8e2:	8b 45 08             	mov    0x8(%ebp),%eax
 8e5:	c1 e0 03             	shl    $0x3,%eax
 8e8:	89 04 24             	mov    %eax,(%esp)
 8eb:	e8 10 fc ff ff       	call   500 <sbrk>
 8f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8f3:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8f7:	75 07                	jne    900 <morecore+0x34>
    return 0;
 8f9:	b8 00 00 00 00       	mov    $0x0,%eax
 8fe:	eb 22                	jmp    922 <morecore+0x56>
  hp = (Header*)p;
 900:	8b 45 f4             	mov    -0xc(%ebp),%eax
 903:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 906:	8b 45 f0             	mov    -0x10(%ebp),%eax
 909:	8b 55 08             	mov    0x8(%ebp),%edx
 90c:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 90f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 912:	83 c0 08             	add    $0x8,%eax
 915:	89 04 24             	mov    %eax,(%esp)
 918:	e8 ce fe ff ff       	call   7eb <free>
  return freep;
 91d:	a1 28 0d 00 00       	mov    0xd28,%eax
}
 922:	c9                   	leave  
 923:	c3                   	ret    

00000924 <malloc>:

void*
malloc(uint nbytes)
{
 924:	55                   	push   %ebp
 925:	89 e5                	mov    %esp,%ebp
 927:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92a:	8b 45 08             	mov    0x8(%ebp),%eax
 92d:	83 c0 07             	add    $0x7,%eax
 930:	c1 e8 03             	shr    $0x3,%eax
 933:	83 c0 01             	add    $0x1,%eax
 936:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 939:	a1 28 0d 00 00       	mov    0xd28,%eax
 93e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 941:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 945:	75 23                	jne    96a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 947:	c7 45 f0 20 0d 00 00 	movl   $0xd20,-0x10(%ebp)
 94e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 951:	a3 28 0d 00 00       	mov    %eax,0xd28
 956:	a1 28 0d 00 00       	mov    0xd28,%eax
 95b:	a3 20 0d 00 00       	mov    %eax,0xd20
    base.s.size = 0;
 960:	c7 05 24 0d 00 00 00 	movl   $0x0,0xd24
 967:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96d:	8b 00                	mov    (%eax),%eax
 96f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 972:	8b 45 f4             	mov    -0xc(%ebp),%eax
 975:	8b 40 04             	mov    0x4(%eax),%eax
 978:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 97b:	72 4d                	jb     9ca <malloc+0xa6>
      if(p->s.size == nunits)
 97d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 980:	8b 40 04             	mov    0x4(%eax),%eax
 983:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 986:	75 0c                	jne    994 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 988:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98b:	8b 10                	mov    (%eax),%edx
 98d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 990:	89 10                	mov    %edx,(%eax)
 992:	eb 26                	jmp    9ba <malloc+0x96>
      else {
        p->s.size -= nunits;
 994:	8b 45 f4             	mov    -0xc(%ebp),%eax
 997:	8b 40 04             	mov    0x4(%eax),%eax
 99a:	2b 45 ec             	sub    -0x14(%ebp),%eax
 99d:	89 c2                	mov    %eax,%edx
 99f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 9a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a8:	8b 40 04             	mov    0x4(%eax),%eax
 9ab:	c1 e0 03             	shl    $0x3,%eax
 9ae:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 9b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 9b7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9bd:	a3 28 0d 00 00       	mov    %eax,0xd28
      return (void*)(p + 1);
 9c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9c5:	83 c0 08             	add    $0x8,%eax
 9c8:	eb 38                	jmp    a02 <malloc+0xde>
    }
    if(p == freep)
 9ca:	a1 28 0d 00 00       	mov    0xd28,%eax
 9cf:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9d2:	75 1b                	jne    9ef <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 9d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9d7:	89 04 24             	mov    %eax,(%esp)
 9da:	e8 ed fe ff ff       	call   8cc <morecore>
 9df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9e2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9e6:	75 07                	jne    9ef <malloc+0xcb>
        return 0;
 9e8:	b8 00 00 00 00       	mov    $0x0,%eax
 9ed:	eb 13                	jmp    a02 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f8:	8b 00                	mov    (%eax),%eax
 9fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 9fd:	e9 70 ff ff ff       	jmp    972 <malloc+0x4e>
}
 a02:	c9                   	leave  
 a03:	c3                   	ret    
