
_schedtest:     file format elf32-i386


Disassembly of section .text:

00000000 <rand>:


unsigned short lfsr = 0xACE1u;
unsigned bit;

unsigned rand() {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
	bit  = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) ) & 1;
   3:	0f b7 05 b0 0b 00 00 	movzwl 0xbb0,%eax
   a:	0f b7 d0             	movzwl %ax,%edx
   d:	0f b7 05 b0 0b 00 00 	movzwl 0xbb0,%eax
  14:	66 c1 e8 02          	shr    $0x2,%ax
  18:	0f b7 c0             	movzwl %ax,%eax
  1b:	31 c2                	xor    %eax,%edx
  1d:	0f b7 05 b0 0b 00 00 	movzwl 0xbb0,%eax
  24:	66 c1 e8 03          	shr    $0x3,%ax
  28:	0f b7 c0             	movzwl %ax,%eax
  2b:	31 c2                	xor    %eax,%edx
  2d:	0f b7 05 b0 0b 00 00 	movzwl 0xbb0,%eax
  34:	66 c1 e8 05          	shr    $0x5,%ax
  38:	0f b7 c0             	movzwl %ax,%eax
  3b:	31 d0                	xor    %edx,%eax
  3d:	83 e0 01             	and    $0x1,%eax
  40:	a3 d0 0b 00 00       	mov    %eax,0xbd0
	return lfsr =  (lfsr >> 1) | (bit << 15);
  45:	0f b7 05 b0 0b 00 00 	movzwl 0xbb0,%eax
  4c:	66 d1 e8             	shr    %ax
  4f:	89 c2                	mov    %eax,%edx
  51:	a1 d0 0b 00 00       	mov    0xbd0,%eax
  56:	c1 e0 0f             	shl    $0xf,%eax
  59:	09 d0                	or     %edx,%eax
  5b:	66 a3 b0 0b 00 00    	mov    %ax,0xbb0
  61:	0f b7 05 b0 0b 00 00 	movzwl 0xbb0,%eax
  68:	0f b7 c0             	movzwl %ax,%eax
}
  6b:	5d                   	pop    %ebp
  6c:	c3                   	ret    

0000006d <main>:

	// printf(1, "hello %d \n", getpid());

	// exit();
int main(int argc, char *argv[])
{
  6d:	55                   	push   %ebp
  6e:	89 e5                	mov    %esp,%ebp
  70:	53                   	push   %ebx
  71:	83 e4 f0             	and    $0xfffffff0,%esp
  74:	83 ec 30             	sub    $0x30,%esp
	int process_count;
	int pid = -1;
  77:	c7 44 24 28 ff ff ff 	movl   $0xffffffff,0x28(%esp)
  7e:	ff 
	
	for (process_count = 0; process_count <= 2; process_count++) {
  7f:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  86:	00 
  87:	eb 0e                	jmp    97 <main+0x2a>
		pid = fork();
  89:	e8 0d 03 00 00       	call   39b <fork>
  8e:	89 44 24 28          	mov    %eax,0x28(%esp)
int main(int argc, char *argv[])
{
	int process_count;
	int pid = -1;
	
	for (process_count = 0; process_count <= 2; process_count++) {
  92:	83 44 24 2c 01       	addl   $0x1,0x2c(%esp)
  97:	83 7c 24 2c 02       	cmpl   $0x2,0x2c(%esp)
  9c:	7e eb                	jle    89 <main+0x1c>
		pid = fork();
	}

	if (pid == 0) { // Children execute the test
  9e:	83 7c 24 28 00       	cmpl   $0x0,0x28(%esp)
  a3:	0f 85 82 00 00 00    	jne    12b <main+0xbe>
		int i, j, garbage;
		
		for (i = 0; i < 20; i++) {
  a9:	c7 44 24 24 00 00 00 	movl   $0x0,0x24(%esp)
  b0:	00 
  b1:	eb 4d                	jmp    100 <main+0x93>
			int rand_num = rand() * (100 * getpid());
  b3:	e8 48 ff ff ff       	call   0 <rand>
  b8:	89 c3                	mov    %eax,%ebx
  ba:	e8 64 03 00 00       	call   423 <getpid>
  bf:	0f af c3             	imul   %ebx,%eax
  c2:	6b c0 64             	imul   $0x64,%eax,%eax
  c5:	89 44 24 18          	mov    %eax,0x18(%esp)
			garbage = 0;
  c9:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  d0:	00 
			
			for (j = 0; j < rand_num; j++) {
  d1:	c7 44 24 20 00 00 00 	movl   $0x0,0x20(%esp)
  d8:	00 
  d9:	eb 0a                	jmp    e5 <main+0x78>
				garbage += 1;
  db:	83 44 24 1c 01       	addl   $0x1,0x1c(%esp)
		
		for (i = 0; i < 20; i++) {
			int rand_num = rand() * (100 * getpid());
			garbage = 0;
			
			for (j = 0; j < rand_num; j++) {
  e0:	83 44 24 20 01       	addl   $0x1,0x20(%esp)
  e5:	8b 44 24 20          	mov    0x20(%esp),%eax
  e9:	3b 44 24 18          	cmp    0x18(%esp),%eax
  ed:	7c ec                	jl     db <main+0x6e>
				garbage += 1;
			} 
			
			sleep(0);
  ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  f6:	e8 38 03 00 00       	call   433 <sleep>
	}

	if (pid == 0) { // Children execute the test
		int i, j, garbage;
		
		for (i = 0; i < 20; i++) {
  fb:	83 44 24 24 01       	addl   $0x1,0x24(%esp)
 100:	83 7c 24 24 13       	cmpl   $0x13,0x24(%esp)
 105:	7e ac                	jle    b3 <main+0x46>
			} 
			
			sleep(0);
		}
	
		printf(1, "Process %d bursts: ", getpid());
 107:	e8 17 03 00 00       	call   423 <getpid>
 10c:	89 44 24 08          	mov    %eax,0x8(%esp)
 110:	c7 44 24 04 2f 09 00 	movl   $0x92f,0x4(%esp)
 117:	00 
 118:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 11f:	e8 3f 04 00 00       	call   563 <printf>
		print_bursts();
 124:	e8 2a 03 00 00       	call   453 <print_bursts>
 129:	eb 0b                	jmp    136 <main+0xc9>
	}
	else {
		while (wait() != -1);
 12b:	90                   	nop
 12c:	e8 7a 02 00 00       	call   3ab <wait>
 131:	83 f8 ff             	cmp    $0xffffffff,%eax
 134:	75 f6                	jne    12c <main+0xbf>
	}
	
  exit();
 136:	e8 68 02 00 00       	call   3a3 <exit>

0000013b <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 13b:	55                   	push   %ebp
 13c:	89 e5                	mov    %esp,%ebp
 13e:	57                   	push   %edi
 13f:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 140:	8b 4d 08             	mov    0x8(%ebp),%ecx
 143:	8b 55 10             	mov    0x10(%ebp),%edx
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	89 cb                	mov    %ecx,%ebx
 14b:	89 df                	mov    %ebx,%edi
 14d:	89 d1                	mov    %edx,%ecx
 14f:	fc                   	cld    
 150:	f3 aa                	rep stos %al,%es:(%edi)
 152:	89 ca                	mov    %ecx,%edx
 154:	89 fb                	mov    %edi,%ebx
 156:	89 5d 08             	mov    %ebx,0x8(%ebp)
 159:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 15c:	5b                   	pop    %ebx
 15d:	5f                   	pop    %edi
 15e:	5d                   	pop    %ebp
 15f:	c3                   	ret    

00000160 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 160:	55                   	push   %ebp
 161:	89 e5                	mov    %esp,%ebp
 163:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 166:	8b 45 08             	mov    0x8(%ebp),%eax
 169:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 16c:	90                   	nop
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
 170:	8d 50 01             	lea    0x1(%eax),%edx
 173:	89 55 08             	mov    %edx,0x8(%ebp)
 176:	8b 55 0c             	mov    0xc(%ebp),%edx
 179:	8d 4a 01             	lea    0x1(%edx),%ecx
 17c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 17f:	0f b6 12             	movzbl (%edx),%edx
 182:	88 10                	mov    %dl,(%eax)
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	84 c0                	test   %al,%al
 189:	75 e2                	jne    16d <strcpy+0xd>
    ;
  return os;
 18b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 18e:	c9                   	leave  
 18f:	c3                   	ret    

00000190 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 193:	eb 08                	jmp    19d <strcmp+0xd>
    p++, q++;
 195:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 199:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 19d:	8b 45 08             	mov    0x8(%ebp),%eax
 1a0:	0f b6 00             	movzbl (%eax),%eax
 1a3:	84 c0                	test   %al,%al
 1a5:	74 10                	je     1b7 <strcmp+0x27>
 1a7:	8b 45 08             	mov    0x8(%ebp),%eax
 1aa:	0f b6 10             	movzbl (%eax),%edx
 1ad:	8b 45 0c             	mov    0xc(%ebp),%eax
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	38 c2                	cmp    %al,%dl
 1b5:	74 de                	je     195 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 1b7:	8b 45 08             	mov    0x8(%ebp),%eax
 1ba:	0f b6 00             	movzbl (%eax),%eax
 1bd:	0f b6 d0             	movzbl %al,%edx
 1c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c3:	0f b6 00             	movzbl (%eax),%eax
 1c6:	0f b6 c0             	movzbl %al,%eax
 1c9:	29 c2                	sub    %eax,%edx
 1cb:	89 d0                	mov    %edx,%eax
}
 1cd:	5d                   	pop    %ebp
 1ce:	c3                   	ret    

000001cf <strlen>:

uint
strlen(char *s)
{
 1cf:	55                   	push   %ebp
 1d0:	89 e5                	mov    %esp,%ebp
 1d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1dc:	eb 04                	jmp    1e2 <strlen+0x13>
 1de:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1e5:	8b 45 08             	mov    0x8(%ebp),%eax
 1e8:	01 d0                	add    %edx,%eax
 1ea:	0f b6 00             	movzbl (%eax),%eax
 1ed:	84 c0                	test   %al,%al
 1ef:	75 ed                	jne    1de <strlen+0xf>
    ;
  return n;
 1f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1f4:	c9                   	leave  
 1f5:	c3                   	ret    

000001f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f6:	55                   	push   %ebp
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1fc:	8b 45 10             	mov    0x10(%ebp),%eax
 1ff:	89 44 24 08          	mov    %eax,0x8(%esp)
 203:	8b 45 0c             	mov    0xc(%ebp),%eax
 206:	89 44 24 04          	mov    %eax,0x4(%esp)
 20a:	8b 45 08             	mov    0x8(%ebp),%eax
 20d:	89 04 24             	mov    %eax,(%esp)
 210:	e8 26 ff ff ff       	call   13b <stosb>
  return dst;
 215:	8b 45 08             	mov    0x8(%ebp),%eax
}
 218:	c9                   	leave  
 219:	c3                   	ret    

0000021a <strchr>:

char*
strchr(const char *s, char c)
{
 21a:	55                   	push   %ebp
 21b:	89 e5                	mov    %esp,%ebp
 21d:	83 ec 04             	sub    $0x4,%esp
 220:	8b 45 0c             	mov    0xc(%ebp),%eax
 223:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 226:	eb 14                	jmp    23c <strchr+0x22>
    if(*s == c)
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	0f b6 00             	movzbl (%eax),%eax
 22e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 231:	75 05                	jne    238 <strchr+0x1e>
      return (char*)s;
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	eb 13                	jmp    24b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 238:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	0f b6 00             	movzbl (%eax),%eax
 242:	84 c0                	test   %al,%al
 244:	75 e2                	jne    228 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 246:	b8 00 00 00 00       	mov    $0x0,%eax
}
 24b:	c9                   	leave  
 24c:	c3                   	ret    

0000024d <gets>:

char*
gets(char *buf, int max)
{
 24d:	55                   	push   %ebp
 24e:	89 e5                	mov    %esp,%ebp
 250:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 253:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 25a:	eb 4c                	jmp    2a8 <gets+0x5b>
    cc = read(0, &c, 1);
 25c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 263:	00 
 264:	8d 45 ef             	lea    -0x11(%ebp),%eax
 267:	89 44 24 04          	mov    %eax,0x4(%esp)
 26b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 272:	e8 44 01 00 00       	call   3bb <read>
 277:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 27a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 27e:	7f 02                	jg     282 <gets+0x35>
      break;
 280:	eb 31                	jmp    2b3 <gets+0x66>
    buf[i++] = c;
 282:	8b 45 f4             	mov    -0xc(%ebp),%eax
 285:	8d 50 01             	lea    0x1(%eax),%edx
 288:	89 55 f4             	mov    %edx,-0xc(%ebp)
 28b:	89 c2                	mov    %eax,%edx
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	01 c2                	add    %eax,%edx
 292:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 296:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 298:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 29c:	3c 0a                	cmp    $0xa,%al
 29e:	74 13                	je     2b3 <gets+0x66>
 2a0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2a4:	3c 0d                	cmp    $0xd,%al
 2a6:	74 0b                	je     2b3 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ab:	83 c0 01             	add    $0x1,%eax
 2ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2b1:	7c a9                	jl     25c <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2b6:	8b 45 08             	mov    0x8(%ebp),%eax
 2b9:	01 d0                	add    %edx,%eax
 2bb:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c1:	c9                   	leave  
 2c2:	c3                   	ret    

000002c3 <stat>:

int
stat(char *n, struct stat *st)
{
 2c3:	55                   	push   %ebp
 2c4:	89 e5                	mov    %esp,%ebp
 2c6:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 2d0:	00 
 2d1:	8b 45 08             	mov    0x8(%ebp),%eax
 2d4:	89 04 24             	mov    %eax,(%esp)
 2d7:	e8 07 01 00 00       	call   3e3 <open>
 2dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2e3:	79 07                	jns    2ec <stat+0x29>
    return -1;
 2e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2ea:	eb 23                	jmp    30f <stat+0x4c>
  r = fstat(fd, st);
 2ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 2f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f6:	89 04 24             	mov    %eax,(%esp)
 2f9:	e8 fd 00 00 00       	call   3fb <fstat>
 2fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 301:	8b 45 f4             	mov    -0xc(%ebp),%eax
 304:	89 04 24             	mov    %eax,(%esp)
 307:	e8 bf 00 00 00       	call   3cb <close>
  return r;
 30c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 30f:	c9                   	leave  
 310:	c3                   	ret    

00000311 <atoi>:

int
atoi(const char *s)
{
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 317:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 31e:	eb 25                	jmp    345 <atoi+0x34>
    n = n*10 + *s++ - '0';
 320:	8b 55 fc             	mov    -0x4(%ebp),%edx
 323:	89 d0                	mov    %edx,%eax
 325:	c1 e0 02             	shl    $0x2,%eax
 328:	01 d0                	add    %edx,%eax
 32a:	01 c0                	add    %eax,%eax
 32c:	89 c1                	mov    %eax,%ecx
 32e:	8b 45 08             	mov    0x8(%ebp),%eax
 331:	8d 50 01             	lea    0x1(%eax),%edx
 334:	89 55 08             	mov    %edx,0x8(%ebp)
 337:	0f b6 00             	movzbl (%eax),%eax
 33a:	0f be c0             	movsbl %al,%eax
 33d:	01 c8                	add    %ecx,%eax
 33f:	83 e8 30             	sub    $0x30,%eax
 342:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 345:	8b 45 08             	mov    0x8(%ebp),%eax
 348:	0f b6 00             	movzbl (%eax),%eax
 34b:	3c 2f                	cmp    $0x2f,%al
 34d:	7e 0a                	jle    359 <atoi+0x48>
 34f:	8b 45 08             	mov    0x8(%ebp),%eax
 352:	0f b6 00             	movzbl (%eax),%eax
 355:	3c 39                	cmp    $0x39,%al
 357:	7e c7                	jle    320 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 359:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 35c:	c9                   	leave  
 35d:	c3                   	ret    

0000035e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 35e:	55                   	push   %ebp
 35f:	89 e5                	mov    %esp,%ebp
 361:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 364:	8b 45 08             	mov    0x8(%ebp),%eax
 367:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 36a:	8b 45 0c             	mov    0xc(%ebp),%eax
 36d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 370:	eb 17                	jmp    389 <memmove+0x2b>
    *dst++ = *src++;
 372:	8b 45 fc             	mov    -0x4(%ebp),%eax
 375:	8d 50 01             	lea    0x1(%eax),%edx
 378:	89 55 fc             	mov    %edx,-0x4(%ebp)
 37b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 37e:	8d 4a 01             	lea    0x1(%edx),%ecx
 381:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 384:	0f b6 12             	movzbl (%edx),%edx
 387:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 389:	8b 45 10             	mov    0x10(%ebp),%eax
 38c:	8d 50 ff             	lea    -0x1(%eax),%edx
 38f:	89 55 10             	mov    %edx,0x10(%ebp)
 392:	85 c0                	test   %eax,%eax
 394:	7f dc                	jg     372 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 396:	8b 45 08             	mov    0x8(%ebp),%eax
}
 399:	c9                   	leave  
 39a:	c3                   	ret    

0000039b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 39b:	b8 01 00 00 00       	mov    $0x1,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <exit>:
SYSCALL(exit)
 3a3:	b8 02 00 00 00       	mov    $0x2,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <wait>:
SYSCALL(wait)
 3ab:	b8 03 00 00 00       	mov    $0x3,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <pipe>:
SYSCALL(pipe)
 3b3:	b8 04 00 00 00       	mov    $0x4,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <read>:
SYSCALL(read)
 3bb:	b8 05 00 00 00       	mov    $0x5,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	ret    

000003c3 <write>:
SYSCALL(write)
 3c3:	b8 10 00 00 00       	mov    $0x10,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	ret    

000003cb <close>:
SYSCALL(close)
 3cb:	b8 15 00 00 00       	mov    $0x15,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <kill>:
SYSCALL(kill)
 3d3:	b8 06 00 00 00       	mov    $0x6,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <exec>:
SYSCALL(exec)
 3db:	b8 07 00 00 00       	mov    $0x7,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    

000003e3 <open>:
SYSCALL(open)
 3e3:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e8:	cd 40                	int    $0x40
 3ea:	c3                   	ret    

000003eb <mknod>:
SYSCALL(mknod)
 3eb:	b8 11 00 00 00       	mov    $0x11,%eax
 3f0:	cd 40                	int    $0x40
 3f2:	c3                   	ret    

000003f3 <unlink>:
SYSCALL(unlink)
 3f3:	b8 12 00 00 00       	mov    $0x12,%eax
 3f8:	cd 40                	int    $0x40
 3fa:	c3                   	ret    

000003fb <fstat>:
SYSCALL(fstat)
 3fb:	b8 08 00 00 00       	mov    $0x8,%eax
 400:	cd 40                	int    $0x40
 402:	c3                   	ret    

00000403 <link>:
SYSCALL(link)
 403:	b8 13 00 00 00       	mov    $0x13,%eax
 408:	cd 40                	int    $0x40
 40a:	c3                   	ret    

0000040b <mkdir>:
SYSCALL(mkdir)
 40b:	b8 14 00 00 00       	mov    $0x14,%eax
 410:	cd 40                	int    $0x40
 412:	c3                   	ret    

00000413 <chdir>:
SYSCALL(chdir)
 413:	b8 09 00 00 00       	mov    $0x9,%eax
 418:	cd 40                	int    $0x40
 41a:	c3                   	ret    

0000041b <dup>:
SYSCALL(dup)
 41b:	b8 0a 00 00 00       	mov    $0xa,%eax
 420:	cd 40                	int    $0x40
 422:	c3                   	ret    

00000423 <getpid>:
SYSCALL(getpid)
 423:	b8 0b 00 00 00       	mov    $0xb,%eax
 428:	cd 40                	int    $0x40
 42a:	c3                   	ret    

0000042b <sbrk>:
SYSCALL(sbrk)
 42b:	b8 0c 00 00 00       	mov    $0xc,%eax
 430:	cd 40                	int    $0x40
 432:	c3                   	ret    

00000433 <sleep>:
SYSCALL(sleep)
 433:	b8 0d 00 00 00       	mov    $0xd,%eax
 438:	cd 40                	int    $0x40
 43a:	c3                   	ret    

0000043b <uptime>:
SYSCALL(uptime)
 43b:	b8 0e 00 00 00       	mov    $0xe,%eax
 440:	cd 40                	int    $0x40
 442:	c3                   	ret    

00000443 <startBurst>:
SYSCALL(startBurst)
 443:	b8 16 00 00 00       	mov    $0x16,%eax
 448:	cd 40                	int    $0x40
 44a:	c3                   	ret    

0000044b <endBurst>:
SYSCALL(endBurst)
 44b:	b8 17 00 00 00       	mov    $0x17,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <print_bursts>:
SYSCALL(print_bursts)
 453:	b8 18 00 00 00       	mov    $0x18,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret    

0000045b <thread_create>:
SYSCALL(thread_create)
 45b:	b8 19 00 00 00       	mov    $0x19,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret    

00000463 <thread_join>:
SYSCALL(thread_join)
 463:	b8 1a 00 00 00       	mov    $0x1a,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <mtx_create>:
SYSCALL(mtx_create)
 46b:	b8 1b 00 00 00       	mov    $0x1b,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <mtx_lock>:
SYSCALL(mtx_lock)
 473:	b8 1c 00 00 00       	mov    $0x1c,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <mtx_unlock>:
SYSCALL(mtx_unlock)
 47b:	b8 1d 00 00 00       	mov    $0x1d,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret    

00000483 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 483:	55                   	push   %ebp
 484:	89 e5                	mov    %esp,%ebp
 486:	83 ec 18             	sub    $0x18,%esp
 489:	8b 45 0c             	mov    0xc(%ebp),%eax
 48c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 48f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 496:	00 
 497:	8d 45 f4             	lea    -0xc(%ebp),%eax
 49a:	89 44 24 04          	mov    %eax,0x4(%esp)
 49e:	8b 45 08             	mov    0x8(%ebp),%eax
 4a1:	89 04 24             	mov    %eax,(%esp)
 4a4:	e8 1a ff ff ff       	call   3c3 <write>
}
 4a9:	c9                   	leave  
 4aa:	c3                   	ret    

000004ab <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ab:	55                   	push   %ebp
 4ac:	89 e5                	mov    %esp,%ebp
 4ae:	56                   	push   %esi
 4af:	53                   	push   %ebx
 4b0:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4ba:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4be:	74 17                	je     4d7 <printint+0x2c>
 4c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4c4:	79 11                	jns    4d7 <printint+0x2c>
    neg = 1;
 4c6:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d0:	f7 d8                	neg    %eax
 4d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4d5:	eb 06                	jmp    4dd <printint+0x32>
  } else {
    x = xx;
 4d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 4e4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 4e7:	8d 41 01             	lea    0x1(%ecx),%eax
 4ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
 4ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
 4f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4f3:	ba 00 00 00 00       	mov    $0x0,%edx
 4f8:	f7 f3                	div    %ebx
 4fa:	89 d0                	mov    %edx,%eax
 4fc:	0f b6 80 b2 0b 00 00 	movzbl 0xbb2(%eax),%eax
 503:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 507:	8b 75 10             	mov    0x10(%ebp),%esi
 50a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 50d:	ba 00 00 00 00       	mov    $0x0,%edx
 512:	f7 f6                	div    %esi
 514:	89 45 ec             	mov    %eax,-0x14(%ebp)
 517:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 51b:	75 c7                	jne    4e4 <printint+0x39>
  if(neg)
 51d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 521:	74 10                	je     533 <printint+0x88>
    buf[i++] = '-';
 523:	8b 45 f4             	mov    -0xc(%ebp),%eax
 526:	8d 50 01             	lea    0x1(%eax),%edx
 529:	89 55 f4             	mov    %edx,-0xc(%ebp)
 52c:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 531:	eb 1f                	jmp    552 <printint+0xa7>
 533:	eb 1d                	jmp    552 <printint+0xa7>
    putc(fd, buf[i]);
 535:	8d 55 dc             	lea    -0x24(%ebp),%edx
 538:	8b 45 f4             	mov    -0xc(%ebp),%eax
 53b:	01 d0                	add    %edx,%eax
 53d:	0f b6 00             	movzbl (%eax),%eax
 540:	0f be c0             	movsbl %al,%eax
 543:	89 44 24 04          	mov    %eax,0x4(%esp)
 547:	8b 45 08             	mov    0x8(%ebp),%eax
 54a:	89 04 24             	mov    %eax,(%esp)
 54d:	e8 31 ff ff ff       	call   483 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 552:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 556:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 55a:	79 d9                	jns    535 <printint+0x8a>
    putc(fd, buf[i]);
}
 55c:	83 c4 30             	add    $0x30,%esp
 55f:	5b                   	pop    %ebx
 560:	5e                   	pop    %esi
 561:	5d                   	pop    %ebp
 562:	c3                   	ret    

00000563 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 563:	55                   	push   %ebp
 564:	89 e5                	mov    %esp,%ebp
 566:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 569:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 570:	8d 45 0c             	lea    0xc(%ebp),%eax
 573:	83 c0 04             	add    $0x4,%eax
 576:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 579:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 580:	e9 7c 01 00 00       	jmp    701 <printf+0x19e>
    c = fmt[i] & 0xff;
 585:	8b 55 0c             	mov    0xc(%ebp),%edx
 588:	8b 45 f0             	mov    -0x10(%ebp),%eax
 58b:	01 d0                	add    %edx,%eax
 58d:	0f b6 00             	movzbl (%eax),%eax
 590:	0f be c0             	movsbl %al,%eax
 593:	25 ff 00 00 00       	and    $0xff,%eax
 598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 59b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 59f:	75 2c                	jne    5cd <printf+0x6a>
      if(c == '%'){
 5a1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a5:	75 0c                	jne    5b3 <printf+0x50>
        state = '%';
 5a7:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5ae:	e9 4a 01 00 00       	jmp    6fd <printf+0x19a>
      } else {
        putc(fd, c);
 5b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5b6:	0f be c0             	movsbl %al,%eax
 5b9:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bd:	8b 45 08             	mov    0x8(%ebp),%eax
 5c0:	89 04 24             	mov    %eax,(%esp)
 5c3:	e8 bb fe ff ff       	call   483 <putc>
 5c8:	e9 30 01 00 00       	jmp    6fd <printf+0x19a>
      }
    } else if(state == '%'){
 5cd:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5d1:	0f 85 26 01 00 00    	jne    6fd <printf+0x19a>
      if(c == 'd'){
 5d7:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5db:	75 2d                	jne    60a <printf+0xa7>
        printint(fd, *ap, 10, 1);
 5dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5e0:	8b 00                	mov    (%eax),%eax
 5e2:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 5e9:	00 
 5ea:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 5f1:	00 
 5f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5f6:	8b 45 08             	mov    0x8(%ebp),%eax
 5f9:	89 04 24             	mov    %eax,(%esp)
 5fc:	e8 aa fe ff ff       	call   4ab <printint>
        ap++;
 601:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 605:	e9 ec 00 00 00       	jmp    6f6 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 60a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 60e:	74 06                	je     616 <printf+0xb3>
 610:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 614:	75 2d                	jne    643 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 616:	8b 45 e8             	mov    -0x18(%ebp),%eax
 619:	8b 00                	mov    (%eax),%eax
 61b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 622:	00 
 623:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 62a:	00 
 62b:	89 44 24 04          	mov    %eax,0x4(%esp)
 62f:	8b 45 08             	mov    0x8(%ebp),%eax
 632:	89 04 24             	mov    %eax,(%esp)
 635:	e8 71 fe ff ff       	call   4ab <printint>
        ap++;
 63a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 63e:	e9 b3 00 00 00       	jmp    6f6 <printf+0x193>
      } else if(c == 's'){
 643:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 647:	75 45                	jne    68e <printf+0x12b>
        s = (char*)*ap;
 649:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 651:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 659:	75 09                	jne    664 <printf+0x101>
          s = "(null)";
 65b:	c7 45 f4 43 09 00 00 	movl   $0x943,-0xc(%ebp)
        while(*s != 0){
 662:	eb 1e                	jmp    682 <printf+0x11f>
 664:	eb 1c                	jmp    682 <printf+0x11f>
          putc(fd, *s);
 666:	8b 45 f4             	mov    -0xc(%ebp),%eax
 669:	0f b6 00             	movzbl (%eax),%eax
 66c:	0f be c0             	movsbl %al,%eax
 66f:	89 44 24 04          	mov    %eax,0x4(%esp)
 673:	8b 45 08             	mov    0x8(%ebp),%eax
 676:	89 04 24             	mov    %eax,(%esp)
 679:	e8 05 fe ff ff       	call   483 <putc>
          s++;
 67e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 682:	8b 45 f4             	mov    -0xc(%ebp),%eax
 685:	0f b6 00             	movzbl (%eax),%eax
 688:	84 c0                	test   %al,%al
 68a:	75 da                	jne    666 <printf+0x103>
 68c:	eb 68                	jmp    6f6 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 68e:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 692:	75 1d                	jne    6b1 <printf+0x14e>
        putc(fd, *ap);
 694:	8b 45 e8             	mov    -0x18(%ebp),%eax
 697:	8b 00                	mov    (%eax),%eax
 699:	0f be c0             	movsbl %al,%eax
 69c:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a0:	8b 45 08             	mov    0x8(%ebp),%eax
 6a3:	89 04 24             	mov    %eax,(%esp)
 6a6:	e8 d8 fd ff ff       	call   483 <putc>
        ap++;
 6ab:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6af:	eb 45                	jmp    6f6 <printf+0x193>
      } else if(c == '%'){
 6b1:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6b5:	75 17                	jne    6ce <printf+0x16b>
        putc(fd, c);
 6b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6ba:	0f be c0             	movsbl %al,%eax
 6bd:	89 44 24 04          	mov    %eax,0x4(%esp)
 6c1:	8b 45 08             	mov    0x8(%ebp),%eax
 6c4:	89 04 24             	mov    %eax,(%esp)
 6c7:	e8 b7 fd ff ff       	call   483 <putc>
 6cc:	eb 28                	jmp    6f6 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6ce:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 6d5:	00 
 6d6:	8b 45 08             	mov    0x8(%ebp),%eax
 6d9:	89 04 24             	mov    %eax,(%esp)
 6dc:	e8 a2 fd ff ff       	call   483 <putc>
        putc(fd, c);
 6e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6e4:	0f be c0             	movsbl %al,%eax
 6e7:	89 44 24 04          	mov    %eax,0x4(%esp)
 6eb:	8b 45 08             	mov    0x8(%ebp),%eax
 6ee:	89 04 24             	mov    %eax,(%esp)
 6f1:	e8 8d fd ff ff       	call   483 <putc>
      }
      state = 0;
 6f6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6fd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 701:	8b 55 0c             	mov    0xc(%ebp),%edx
 704:	8b 45 f0             	mov    -0x10(%ebp),%eax
 707:	01 d0                	add    %edx,%eax
 709:	0f b6 00             	movzbl (%eax),%eax
 70c:	84 c0                	test   %al,%al
 70e:	0f 85 71 fe ff ff    	jne    585 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 714:	c9                   	leave  
 715:	c3                   	ret    

00000716 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 716:	55                   	push   %ebp
 717:	89 e5                	mov    %esp,%ebp
 719:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 71c:	8b 45 08             	mov    0x8(%ebp),%eax
 71f:	83 e8 08             	sub    $0x8,%eax
 722:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 725:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 72a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 72d:	eb 24                	jmp    753 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 732:	8b 00                	mov    (%eax),%eax
 734:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 737:	77 12                	ja     74b <free+0x35>
 739:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 73f:	77 24                	ja     765 <free+0x4f>
 741:	8b 45 fc             	mov    -0x4(%ebp),%eax
 744:	8b 00                	mov    (%eax),%eax
 746:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 749:	77 1a                	ja     765 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74e:	8b 00                	mov    (%eax),%eax
 750:	89 45 fc             	mov    %eax,-0x4(%ebp)
 753:	8b 45 f8             	mov    -0x8(%ebp),%eax
 756:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 759:	76 d4                	jbe    72f <free+0x19>
 75b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75e:	8b 00                	mov    (%eax),%eax
 760:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 763:	76 ca                	jbe    72f <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 765:	8b 45 f8             	mov    -0x8(%ebp),%eax
 768:	8b 40 04             	mov    0x4(%eax),%eax
 76b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 772:	8b 45 f8             	mov    -0x8(%ebp),%eax
 775:	01 c2                	add    %eax,%edx
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	8b 00                	mov    (%eax),%eax
 77c:	39 c2                	cmp    %eax,%edx
 77e:	75 24                	jne    7a4 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 780:	8b 45 f8             	mov    -0x8(%ebp),%eax
 783:	8b 50 04             	mov    0x4(%eax),%edx
 786:	8b 45 fc             	mov    -0x4(%ebp),%eax
 789:	8b 00                	mov    (%eax),%eax
 78b:	8b 40 04             	mov    0x4(%eax),%eax
 78e:	01 c2                	add    %eax,%edx
 790:	8b 45 f8             	mov    -0x8(%ebp),%eax
 793:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 796:	8b 45 fc             	mov    -0x4(%ebp),%eax
 799:	8b 00                	mov    (%eax),%eax
 79b:	8b 10                	mov    (%eax),%edx
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	89 10                	mov    %edx,(%eax)
 7a2:	eb 0a                	jmp    7ae <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a7:	8b 10                	mov    (%eax),%edx
 7a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ac:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b1:	8b 40 04             	mov    0x4(%eax),%eax
 7b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7be:	01 d0                	add    %edx,%eax
 7c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7c3:	75 20                	jne    7e5 <free+0xcf>
    p->s.size += bp->s.size;
 7c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c8:	8b 50 04             	mov    0x4(%eax),%edx
 7cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ce:	8b 40 04             	mov    0x4(%eax),%eax
 7d1:	01 c2                	add    %eax,%edx
 7d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dc:	8b 10                	mov    (%eax),%edx
 7de:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e1:	89 10                	mov    %edx,(%eax)
 7e3:	eb 08                	jmp    7ed <free+0xd7>
  } else
    p->s.ptr = bp;
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7eb:	89 10                	mov    %edx,(%eax)
  freep = p;
 7ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f0:	a3 cc 0b 00 00       	mov    %eax,0xbcc
}
 7f5:	c9                   	leave  
 7f6:	c3                   	ret    

000007f7 <morecore>:

static Header*
morecore(uint nu)
{
 7f7:	55                   	push   %ebp
 7f8:	89 e5                	mov    %esp,%ebp
 7fa:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7fd:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 804:	77 07                	ja     80d <morecore+0x16>
    nu = 4096;
 806:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 80d:	8b 45 08             	mov    0x8(%ebp),%eax
 810:	c1 e0 03             	shl    $0x3,%eax
 813:	89 04 24             	mov    %eax,(%esp)
 816:	e8 10 fc ff ff       	call   42b <sbrk>
 81b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 81e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 822:	75 07                	jne    82b <morecore+0x34>
    return 0;
 824:	b8 00 00 00 00       	mov    $0x0,%eax
 829:	eb 22                	jmp    84d <morecore+0x56>
  hp = (Header*)p;
 82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 831:	8b 45 f0             	mov    -0x10(%ebp),%eax
 834:	8b 55 08             	mov    0x8(%ebp),%edx
 837:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 83a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83d:	83 c0 08             	add    $0x8,%eax
 840:	89 04 24             	mov    %eax,(%esp)
 843:	e8 ce fe ff ff       	call   716 <free>
  return freep;
 848:	a1 cc 0b 00 00       	mov    0xbcc,%eax
}
 84d:	c9                   	leave  
 84e:	c3                   	ret    

0000084f <malloc>:

void*
malloc(uint nbytes)
{
 84f:	55                   	push   %ebp
 850:	89 e5                	mov    %esp,%ebp
 852:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 855:	8b 45 08             	mov    0x8(%ebp),%eax
 858:	83 c0 07             	add    $0x7,%eax
 85b:	c1 e8 03             	shr    $0x3,%eax
 85e:	83 c0 01             	add    $0x1,%eax
 861:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 864:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 869:	89 45 f0             	mov    %eax,-0x10(%ebp)
 86c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 870:	75 23                	jne    895 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 872:	c7 45 f0 c4 0b 00 00 	movl   $0xbc4,-0x10(%ebp)
 879:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87c:	a3 cc 0b 00 00       	mov    %eax,0xbcc
 881:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 886:	a3 c4 0b 00 00       	mov    %eax,0xbc4
    base.s.size = 0;
 88b:	c7 05 c8 0b 00 00 00 	movl   $0x0,0xbc8
 892:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 895:	8b 45 f0             	mov    -0x10(%ebp),%eax
 898:	8b 00                	mov    (%eax),%eax
 89a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 89d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a0:	8b 40 04             	mov    0x4(%eax),%eax
 8a3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8a6:	72 4d                	jb     8f5 <malloc+0xa6>
      if(p->s.size == nunits)
 8a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ab:	8b 40 04             	mov    0x4(%eax),%eax
 8ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8b1:	75 0c                	jne    8bf <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b6:	8b 10                	mov    (%eax),%edx
 8b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bb:	89 10                	mov    %edx,(%eax)
 8bd:	eb 26                	jmp    8e5 <malloc+0x96>
      else {
        p->s.size -= nunits;
 8bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c2:	8b 40 04             	mov    0x4(%eax),%eax
 8c5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8c8:	89 c2                	mov    %eax,%edx
 8ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8cd:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d3:	8b 40 04             	mov    0x4(%eax),%eax
 8d6:	c1 e0 03             	shl    $0x3,%eax
 8d9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8df:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8e2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e8:	a3 cc 0b 00 00       	mov    %eax,0xbcc
      return (void*)(p + 1);
 8ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f0:	83 c0 08             	add    $0x8,%eax
 8f3:	eb 38                	jmp    92d <malloc+0xde>
    }
    if(p == freep)
 8f5:	a1 cc 0b 00 00       	mov    0xbcc,%eax
 8fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 8fd:	75 1b                	jne    91a <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 8ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 902:	89 04 24             	mov    %eax,(%esp)
 905:	e8 ed fe ff ff       	call   7f7 <morecore>
 90a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 90d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 911:	75 07                	jne    91a <malloc+0xcb>
        return 0;
 913:	b8 00 00 00 00       	mov    $0x0,%eax
 918:	eb 13                	jmp    92d <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 920:	8b 45 f4             	mov    -0xc(%ebp),%eax
 923:	8b 00                	mov    (%eax),%eax
 925:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 928:	e9 70 ff ff ff       	jmp    89d <malloc+0x4e>
}
 92d:	c9                   	leave  
 92e:	c3                   	ret    
