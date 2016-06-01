
_professormp2test:     file format elf32-i386


Disassembly of section .text:

00000000 <rand>:
#define NUM_ELEMENTS 100
int mutex;
unsigned short lfsr = 0xACE1u;
unsigned bit;

unsigned rand(){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
	bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) ) & 1;
   3:	0f b7 05 40 0d 00 00 	movzwl 0xd40,%eax
   a:	0f b7 d0             	movzwl %ax,%edx
   d:	0f b7 05 40 0d 00 00 	movzwl 0xd40,%eax
  14:	66 c1 e8 02          	shr    $0x2,%ax
  18:	0f b7 c0             	movzwl %ax,%eax
  1b:	31 c2                	xor    %eax,%edx
  1d:	0f b7 05 40 0d 00 00 	movzwl 0xd40,%eax
  24:	66 c1 e8 03          	shr    $0x3,%ax
  28:	0f b7 c0             	movzwl %ax,%eax
  2b:	31 c2                	xor    %eax,%edx
  2d:	0f b7 05 40 0d 00 00 	movzwl 0xd40,%eax
  34:	66 c1 e8 05          	shr    $0x5,%ax
  38:	0f b7 c0             	movzwl %ax,%eax
  3b:	31 d0                	xor    %edx,%eax
  3d:	83 e0 01             	and    $0x1,%eax
  40:	a3 60 0d 00 00       	mov    %eax,0xd60
	return lfsr =(lfsr >> 1) | (bit << 15);
  45:	0f b7 05 40 0d 00 00 	movzwl 0xd40,%eax
  4c:	66 d1 e8             	shr    %ax
  4f:	89 c2                	mov    %eax,%edx
  51:	a1 60 0d 00 00       	mov    0xd60,%eax
  56:	c1 e0 0f             	shl    $0xf,%eax
  59:	09 d0                	or     %edx,%eax
  5b:	66 a3 40 0d 00 00    	mov    %ax,0xd40
  61:	0f b7 05 40 0d 00 00 	movzwl 0xd40,%eax
  68:	0f b7 c0             	movzwl %ax,%eax
}
  6b:	5d                   	pop    %ebp
  6c:	c3                   	ret    

0000006d <pro>:

void pro(void *arg){
  6d:	55                   	push   %ebp
  6e:	89 e5                	mov    %esp,%ebp
  70:	53                   	push   %ebx
  71:	83 ec 24             	sub    $0x24,%esp
    int *buffer=(int*)arg;
  74:	8b 45 08             	mov    0x8(%ebp),%eax
  77:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int p;
    for(p=1;p<NUM_ELEMENTS;p++){
  7a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  81:	eb 70                	jmp    f3 <pro+0x86>
        mtx_lock(mutex);
  83:	a1 64 0d 00 00       	mov    0xd64,%eax
  88:	89 04 24             	mov    %eax,(%esp)
  8b:	e8 27 05 00 00       	call   5b7 <mtx_lock>
        //printf(1," before Producer put %d\n",buffer[p]);
        //buffer[p]=p*5;
        buffer[p]=rand();
  90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  9d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
  a0:	e8 5b ff ff ff       	call   0 <rand>
  a5:	89 03                	mov    %eax,(%ebx)
        printf(1,"Producer put %d\n",buffer[p]);
  a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  aa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  b4:	01 d0                	add    %edx,%eax
  b6:	8b 00                	mov    (%eax),%eax
  b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  bc:	c7 44 24 04 73 0a 00 	movl   $0xa73,0x4(%esp)
  c3:	00 
  c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  cb:	e8 d7 05 00 00       	call   6a7 <printf>
        mtx_unlock(mutex);
  d0:	a1 64 0d 00 00       	mov    0xd64,%eax
  d5:	89 04 24             	mov    %eax,(%esp)
  d8:	e8 e2 04 00 00       	call   5bf <mtx_unlock>
        if(p==(NUM_ELEMENTS/2)){
  dd:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
  e1:	75 0c                	jne    ef <pro+0x82>
            sleep(1);
  e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ea:	e8 88 04 00 00       	call   577 <sleep>
}

void pro(void *arg){
    int *buffer=(int*)arg;
    int p;
    for(p=1;p<NUM_ELEMENTS;p++){
  ef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  f3:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
  f7:	7e 8a                	jle    83 <pro+0x16>
        mtx_unlock(mutex);
        if(p==(NUM_ELEMENTS/2)){
            sleep(1);
        }
    }
    exit();
  f9:	e8 e9 03 00 00       	call   4e7 <exit>

000000fe <con>:
}
void con(void *arg){
  fe:	55                   	push   %ebp
  ff:	89 e5                	mov    %esp,%ebp
 101:	83 ec 28             	sub    $0x28,%esp
    int *buffer=(int*)arg;
 104:	8b 45 08             	mov    0x8(%ebp),%eax
 107:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int c;
    mtx_lock(mutex);
 10a:	a1 64 0d 00 00       	mov    0xd64,%eax
 10f:	89 04 24             	mov    %eax,(%esp)
 112:	e8 a0 04 00 00       	call   5b7 <mtx_lock>
    printf(1,"Consumer has:[");
 117:	c7 44 24 04 84 0a 00 	movl   $0xa84,0x4(%esp)
 11e:	00 
 11f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 126:	e8 7c 05 00 00       	call   6a7 <printf>
    for(c=0;c<NUM_ELEMENTS;c++){
 12b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 132:	eb 58                	jmp    18c <con+0x8e>
        if(buffer[c]!=-1){
 134:	8b 45 f4             	mov    -0xc(%ebp),%eax
 137:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 13e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 141:	01 d0                	add    %edx,%eax
 143:	8b 00                	mov    (%eax),%eax
 145:	83 f8 ff             	cmp    $0xffffffff,%eax
 148:	74 3e                	je     188 <con+0x8a>
            printf(1,"%d,",buffer[c]);
 14a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 14d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 154:	8b 45 f0             	mov    -0x10(%ebp),%eax
 157:	01 d0                	add    %edx,%eax
 159:	8b 00                	mov    (%eax),%eax
 15b:	89 44 24 08          	mov    %eax,0x8(%esp)
 15f:	c7 44 24 04 93 0a 00 	movl   $0xa93,0x4(%esp)
 166:	00 
 167:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 16e:	e8 34 05 00 00       	call   6a7 <printf>
            buffer[c]=-1;
 173:	8b 45 f4             	mov    -0xc(%ebp),%eax
 176:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 17d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 180:	01 d0                	add    %edx,%eax
 182:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
void con(void *arg){
    int *buffer=(int*)arg;
    int c;
    mtx_lock(mutex);
    printf(1,"Consumer has:[");
    for(c=0;c<NUM_ELEMENTS;c++){
 188:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 18c:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 190:	7e a2                	jle    134 <con+0x36>
            printf(1,"%d,",buffer[c]);
            buffer[c]=-1;
            //printf(1,"consumer after %d\n",buffer[0]);
        }
    }
    printf(1,"]\n");
 192:	c7 44 24 04 97 0a 00 	movl   $0xa97,0x4(%esp)
 199:	00 
 19a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1a1:	e8 01 05 00 00       	call   6a7 <printf>
    mtx_unlock(mutex);
 1a6:	a1 64 0d 00 00       	mov    0xd64,%eax
 1ab:	89 04 24             	mov    %eax,(%esp)
 1ae:	e8 0c 04 00 00       	call   5bf <mtx_unlock>
    exit();
 1b3:	e8 2f 03 00 00       	call   4e7 <exit>

000001b8 <main>:
}
int main(int argc,char *argv[]){
 1b8:	55                   	push   %ebp
 1b9:	89 e5                	mov    %esp,%ebp
 1bb:	83 e4 f0             	and    $0xfffffff0,%esp
 1be:	83 ec 30             	sub    $0x30,%esp
    mutex=mtx_create(0);
 1c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1c8:	e8 e2 03 00 00       	call   5af <mtx_create>
 1cd:	a3 64 0d 00 00       	mov    %eax,0xd64
    void(*consumerPtr)(void *)=&con;
 1d2:	c7 44 24 2c fe 00 00 	movl   $0xfe,0x2c(%esp)
 1d9:	00 
    void(*producerPtr)(void *)=&pro;
 1da:	c7 44 24 28 6d 00 00 	movl   $0x6d,0x28(%esp)
 1e1:	00 
    int *main_buffer=(int*)malloc(NUM_ELEMENTS*sizeof(int));
 1e2:	c7 04 24 90 01 00 00 	movl   $0x190,(%esp)
 1e9:	e8 a5 07 00 00       	call   993 <malloc>
 1ee:	89 44 24 24          	mov    %eax,0x24(%esp)
    memset(main_buffer,-1,NUM_ELEMENTS*sizeof(int*));
 1f2:	c7 44 24 08 90 01 00 	movl   $0x190,0x8(%esp)
 1f9:	00 
 1fa:	c7 44 24 04 ff ff ff 	movl   $0xffffffff,0x4(%esp)
 201:	ff 
 202:	8b 44 24 24          	mov    0x24(%esp),%eax
 206:	89 04 24             	mov    %eax,(%esp)
 209:	e8 2c 01 00 00       	call   33a <memset>
    uint *stack=(uint *)malloc(1024);
 20e:	c7 04 24 00 04 00 00 	movl   $0x400,(%esp)
 215:	e8 79 07 00 00       	call   993 <malloc>
 21a:	89 44 24 20          	mov    %eax,0x20(%esp)
    void *return_stack;
    thread_create(producerPtr,(void *)stack,(void *)main_buffer);
 21e:	8b 44 24 24          	mov    0x24(%esp),%eax
 222:	89 44 24 08          	mov    %eax,0x8(%esp)
 226:	8b 44 24 20          	mov    0x20(%esp),%eax
 22a:	89 44 24 04          	mov    %eax,0x4(%esp)
 22e:	8b 44 24 28          	mov    0x28(%esp),%eax
 232:	89 04 24             	mov    %eax,(%esp)
 235:	e8 65 03 00 00       	call   59f <thread_create>
    thread_join((void**)&return_stack);
 23a:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 23e:	89 04 24             	mov    %eax,(%esp)
 241:	e8 61 03 00 00       	call   5a7 <thread_join>
    thread_create(consumerPtr,(void *)stack,(void *)main_buffer);
 246:	8b 44 24 24          	mov    0x24(%esp),%eax
 24a:	89 44 24 08          	mov    %eax,0x8(%esp)
 24e:	8b 44 24 20          	mov    0x20(%esp),%eax
 252:	89 44 24 04          	mov    %eax,0x4(%esp)
 256:	8b 44 24 2c          	mov    0x2c(%esp),%eax
 25a:	89 04 24             	mov    %eax,(%esp)
 25d:	e8 3d 03 00 00       	call   59f <thread_create>
    thread_join((void**)&return_stack);
 262:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 266:	89 04 24             	mov    %eax,(%esp)
 269:	e8 39 03 00 00       	call   5a7 <thread_join>
    free(return_stack);
 26e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 272:	89 04 24             	mov    %eax,(%esp)
 275:	e8 e0 05 00 00       	call   85a <free>
    exit();
 27a:	e8 68 02 00 00       	call   4e7 <exit>

0000027f <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
 282:	57                   	push   %edi
 283:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 284:	8b 4d 08             	mov    0x8(%ebp),%ecx
 287:	8b 55 10             	mov    0x10(%ebp),%edx
 28a:	8b 45 0c             	mov    0xc(%ebp),%eax
 28d:	89 cb                	mov    %ecx,%ebx
 28f:	89 df                	mov    %ebx,%edi
 291:	89 d1                	mov    %edx,%ecx
 293:	fc                   	cld    
 294:	f3 aa                	rep stos %al,%es:(%edi)
 296:	89 ca                	mov    %ecx,%edx
 298:	89 fb                	mov    %edi,%ebx
 29a:	89 5d 08             	mov    %ebx,0x8(%ebp)
 29d:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2a0:	5b                   	pop    %ebx
 2a1:	5f                   	pop    %edi
 2a2:	5d                   	pop    %ebp
 2a3:	c3                   	ret    

000002a4 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2a4:	55                   	push   %ebp
 2a5:	89 e5                	mov    %esp,%ebp
 2a7:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2aa:	8b 45 08             	mov    0x8(%ebp),%eax
 2ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2b0:	90                   	nop
 2b1:	8b 45 08             	mov    0x8(%ebp),%eax
 2b4:	8d 50 01             	lea    0x1(%eax),%edx
 2b7:	89 55 08             	mov    %edx,0x8(%ebp)
 2ba:	8b 55 0c             	mov    0xc(%ebp),%edx
 2bd:	8d 4a 01             	lea    0x1(%edx),%ecx
 2c0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2c3:	0f b6 12             	movzbl (%edx),%edx
 2c6:	88 10                	mov    %dl,(%eax)
 2c8:	0f b6 00             	movzbl (%eax),%eax
 2cb:	84 c0                	test   %al,%al
 2cd:	75 e2                	jne    2b1 <strcpy+0xd>
    ;
  return os;
 2cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d2:	c9                   	leave  
 2d3:	c3                   	ret    

000002d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2d4:	55                   	push   %ebp
 2d5:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2d7:	eb 08                	jmp    2e1 <strcmp+0xd>
    p++, q++;
 2d9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2dd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	0f b6 00             	movzbl (%eax),%eax
 2e7:	84 c0                	test   %al,%al
 2e9:	74 10                	je     2fb <strcmp+0x27>
 2eb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ee:	0f b6 10             	movzbl (%eax),%edx
 2f1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f4:	0f b6 00             	movzbl (%eax),%eax
 2f7:	38 c2                	cmp    %al,%dl
 2f9:	74 de                	je     2d9 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2fb:	8b 45 08             	mov    0x8(%ebp),%eax
 2fe:	0f b6 00             	movzbl (%eax),%eax
 301:	0f b6 d0             	movzbl %al,%edx
 304:	8b 45 0c             	mov    0xc(%ebp),%eax
 307:	0f b6 00             	movzbl (%eax),%eax
 30a:	0f b6 c0             	movzbl %al,%eax
 30d:	29 c2                	sub    %eax,%edx
 30f:	89 d0                	mov    %edx,%eax
}
 311:	5d                   	pop    %ebp
 312:	c3                   	ret    

00000313 <strlen>:

uint
strlen(char *s)
{
 313:	55                   	push   %ebp
 314:	89 e5                	mov    %esp,%ebp
 316:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 319:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 320:	eb 04                	jmp    326 <strlen+0x13>
 322:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 326:	8b 55 fc             	mov    -0x4(%ebp),%edx
 329:	8b 45 08             	mov    0x8(%ebp),%eax
 32c:	01 d0                	add    %edx,%eax
 32e:	0f b6 00             	movzbl (%eax),%eax
 331:	84 c0                	test   %al,%al
 333:	75 ed                	jne    322 <strlen+0xf>
    ;
  return n;
 335:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 338:	c9                   	leave  
 339:	c3                   	ret    

0000033a <memset>:

void*
memset(void *dst, int c, uint n)
{
 33a:	55                   	push   %ebp
 33b:	89 e5                	mov    %esp,%ebp
 33d:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 340:	8b 45 10             	mov    0x10(%ebp),%eax
 343:	89 44 24 08          	mov    %eax,0x8(%esp)
 347:	8b 45 0c             	mov    0xc(%ebp),%eax
 34a:	89 44 24 04          	mov    %eax,0x4(%esp)
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
 351:	89 04 24             	mov    %eax,(%esp)
 354:	e8 26 ff ff ff       	call   27f <stosb>
  return dst;
 359:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35c:	c9                   	leave  
 35d:	c3                   	ret    

0000035e <strchr>:

char*
strchr(const char *s, char c)
{
 35e:	55                   	push   %ebp
 35f:	89 e5                	mov    %esp,%ebp
 361:	83 ec 04             	sub    $0x4,%esp
 364:	8b 45 0c             	mov    0xc(%ebp),%eax
 367:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 36a:	eb 14                	jmp    380 <strchr+0x22>
    if(*s == c)
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
 36f:	0f b6 00             	movzbl (%eax),%eax
 372:	3a 45 fc             	cmp    -0x4(%ebp),%al
 375:	75 05                	jne    37c <strchr+0x1e>
      return (char*)s;
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	eb 13                	jmp    38f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 37c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 380:	8b 45 08             	mov    0x8(%ebp),%eax
 383:	0f b6 00             	movzbl (%eax),%eax
 386:	84 c0                	test   %al,%al
 388:	75 e2                	jne    36c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 38a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 38f:	c9                   	leave  
 390:	c3                   	ret    

00000391 <gets>:

char*
gets(char *buf, int max)
{
 391:	55                   	push   %ebp
 392:	89 e5                	mov    %esp,%ebp
 394:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 397:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 39e:	eb 4c                	jmp    3ec <gets+0x5b>
    cc = read(0, &c, 1);
 3a0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 3a7:	00 
 3a8:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 3af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 3b6:	e8 44 01 00 00       	call   4ff <read>
 3bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3c2:	7f 02                	jg     3c6 <gets+0x35>
      break;
 3c4:	eb 31                	jmp    3f7 <gets+0x66>
    buf[i++] = c;
 3c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c9:	8d 50 01             	lea    0x1(%eax),%edx
 3cc:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3cf:	89 c2                	mov    %eax,%edx
 3d1:	8b 45 08             	mov    0x8(%ebp),%eax
 3d4:	01 c2                	add    %eax,%edx
 3d6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3da:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3dc:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3e0:	3c 0a                	cmp    $0xa,%al
 3e2:	74 13                	je     3f7 <gets+0x66>
 3e4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3e8:	3c 0d                	cmp    $0xd,%al
 3ea:	74 0b                	je     3f7 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ef:	83 c0 01             	add    $0x1,%eax
 3f2:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3f5:	7c a9                	jl     3a0 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3fa:	8b 45 08             	mov    0x8(%ebp),%eax
 3fd:	01 d0                	add    %edx,%eax
 3ff:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 402:	8b 45 08             	mov    0x8(%ebp),%eax
}
 405:	c9                   	leave  
 406:	c3                   	ret    

00000407 <stat>:

int
stat(char *n, struct stat *st)
{
 407:	55                   	push   %ebp
 408:	89 e5                	mov    %esp,%ebp
 40a:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 40d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 414:	00 
 415:	8b 45 08             	mov    0x8(%ebp),%eax
 418:	89 04 24             	mov    %eax,(%esp)
 41b:	e8 07 01 00 00       	call   527 <open>
 420:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 423:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 427:	79 07                	jns    430 <stat+0x29>
    return -1;
 429:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 42e:	eb 23                	jmp    453 <stat+0x4c>
  r = fstat(fd, st);
 430:	8b 45 0c             	mov    0xc(%ebp),%eax
 433:	89 44 24 04          	mov    %eax,0x4(%esp)
 437:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43a:	89 04 24             	mov    %eax,(%esp)
 43d:	e8 fd 00 00 00       	call   53f <fstat>
 442:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 445:	8b 45 f4             	mov    -0xc(%ebp),%eax
 448:	89 04 24             	mov    %eax,(%esp)
 44b:	e8 bf 00 00 00       	call   50f <close>
  return r;
 450:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 453:	c9                   	leave  
 454:	c3                   	ret    

00000455 <atoi>:

int
atoi(const char *s)
{
 455:	55                   	push   %ebp
 456:	89 e5                	mov    %esp,%ebp
 458:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 45b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 462:	eb 25                	jmp    489 <atoi+0x34>
    n = n*10 + *s++ - '0';
 464:	8b 55 fc             	mov    -0x4(%ebp),%edx
 467:	89 d0                	mov    %edx,%eax
 469:	c1 e0 02             	shl    $0x2,%eax
 46c:	01 d0                	add    %edx,%eax
 46e:	01 c0                	add    %eax,%eax
 470:	89 c1                	mov    %eax,%ecx
 472:	8b 45 08             	mov    0x8(%ebp),%eax
 475:	8d 50 01             	lea    0x1(%eax),%edx
 478:	89 55 08             	mov    %edx,0x8(%ebp)
 47b:	0f b6 00             	movzbl (%eax),%eax
 47e:	0f be c0             	movsbl %al,%eax
 481:	01 c8                	add    %ecx,%eax
 483:	83 e8 30             	sub    $0x30,%eax
 486:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	0f b6 00             	movzbl (%eax),%eax
 48f:	3c 2f                	cmp    $0x2f,%al
 491:	7e 0a                	jle    49d <atoi+0x48>
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	0f b6 00             	movzbl (%eax),%eax
 499:	3c 39                	cmp    $0x39,%al
 49b:	7e c7                	jle    464 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 49d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4a0:	c9                   	leave  
 4a1:	c3                   	ret    

000004a2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 4a2:	55                   	push   %ebp
 4a3:	89 e5                	mov    %esp,%ebp
 4a5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 4a8:	8b 45 08             	mov    0x8(%ebp),%eax
 4ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4b4:	eb 17                	jmp    4cd <memmove+0x2b>
    *dst++ = *src++;
 4b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4b9:	8d 50 01             	lea    0x1(%eax),%edx
 4bc:	89 55 fc             	mov    %edx,-0x4(%ebp)
 4bf:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4c2:	8d 4a 01             	lea    0x1(%edx),%ecx
 4c5:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4c8:	0f b6 12             	movzbl (%edx),%edx
 4cb:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4cd:	8b 45 10             	mov    0x10(%ebp),%eax
 4d0:	8d 50 ff             	lea    -0x1(%eax),%edx
 4d3:	89 55 10             	mov    %edx,0x10(%ebp)
 4d6:	85 c0                	test   %eax,%eax
 4d8:	7f dc                	jg     4b6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4dd:	c9                   	leave  
 4de:	c3                   	ret    

000004df <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4df:	b8 01 00 00 00       	mov    $0x1,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	ret    

000004e7 <exit>:
SYSCALL(exit)
 4e7:	b8 02 00 00 00       	mov    $0x2,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	ret    

000004ef <wait>:
SYSCALL(wait)
 4ef:	b8 03 00 00 00       	mov    $0x3,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	ret    

000004f7 <pipe>:
SYSCALL(pipe)
 4f7:	b8 04 00 00 00       	mov    $0x4,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <read>:
SYSCALL(read)
 4ff:	b8 05 00 00 00       	mov    $0x5,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <write>:
SYSCALL(write)
 507:	b8 10 00 00 00       	mov    $0x10,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <close>:
SYSCALL(close)
 50f:	b8 15 00 00 00       	mov    $0x15,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <kill>:
SYSCALL(kill)
 517:	b8 06 00 00 00       	mov    $0x6,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <exec>:
SYSCALL(exec)
 51f:	b8 07 00 00 00       	mov    $0x7,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <open>:
SYSCALL(open)
 527:	b8 0f 00 00 00       	mov    $0xf,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <mknod>:
SYSCALL(mknod)
 52f:	b8 11 00 00 00       	mov    $0x11,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <unlink>:
SYSCALL(unlink)
 537:	b8 12 00 00 00       	mov    $0x12,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <fstat>:
SYSCALL(fstat)
 53f:	b8 08 00 00 00       	mov    $0x8,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <link>:
SYSCALL(link)
 547:	b8 13 00 00 00       	mov    $0x13,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	ret    

0000054f <mkdir>:
SYSCALL(mkdir)
 54f:	b8 14 00 00 00       	mov    $0x14,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	ret    

00000557 <chdir>:
SYSCALL(chdir)
 557:	b8 09 00 00 00       	mov    $0x9,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	ret    

0000055f <dup>:
SYSCALL(dup)
 55f:	b8 0a 00 00 00       	mov    $0xa,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	ret    

00000567 <getpid>:
SYSCALL(getpid)
 567:	b8 0b 00 00 00       	mov    $0xb,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	ret    

0000056f <sbrk>:
SYSCALL(sbrk)
 56f:	b8 0c 00 00 00       	mov    $0xc,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	ret    

00000577 <sleep>:
SYSCALL(sleep)
 577:	b8 0d 00 00 00       	mov    $0xd,%eax
 57c:	cd 40                	int    $0x40
 57e:	c3                   	ret    

0000057f <uptime>:
SYSCALL(uptime)
 57f:	b8 0e 00 00 00       	mov    $0xe,%eax
 584:	cd 40                	int    $0x40
 586:	c3                   	ret    

00000587 <startBurst>:
SYSCALL(startBurst)
 587:	b8 16 00 00 00       	mov    $0x16,%eax
 58c:	cd 40                	int    $0x40
 58e:	c3                   	ret    

0000058f <endBurst>:
SYSCALL(endBurst)
 58f:	b8 17 00 00 00       	mov    $0x17,%eax
 594:	cd 40                	int    $0x40
 596:	c3                   	ret    

00000597 <print_bursts>:
SYSCALL(print_bursts)
 597:	b8 18 00 00 00       	mov    $0x18,%eax
 59c:	cd 40                	int    $0x40
 59e:	c3                   	ret    

0000059f <thread_create>:
SYSCALL(thread_create)
 59f:	b8 19 00 00 00       	mov    $0x19,%eax
 5a4:	cd 40                	int    $0x40
 5a6:	c3                   	ret    

000005a7 <thread_join>:
SYSCALL(thread_join)
 5a7:	b8 1a 00 00 00       	mov    $0x1a,%eax
 5ac:	cd 40                	int    $0x40
 5ae:	c3                   	ret    

000005af <mtx_create>:
SYSCALL(mtx_create)
 5af:	b8 1b 00 00 00       	mov    $0x1b,%eax
 5b4:	cd 40                	int    $0x40
 5b6:	c3                   	ret    

000005b7 <mtx_lock>:
SYSCALL(mtx_lock)
 5b7:	b8 1c 00 00 00       	mov    $0x1c,%eax
 5bc:	cd 40                	int    $0x40
 5be:	c3                   	ret    

000005bf <mtx_unlock>:
SYSCALL(mtx_unlock)
 5bf:	b8 1d 00 00 00       	mov    $0x1d,%eax
 5c4:	cd 40                	int    $0x40
 5c6:	c3                   	ret    

000005c7 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5c7:	55                   	push   %ebp
 5c8:	89 e5                	mov    %esp,%ebp
 5ca:	83 ec 18             	sub    $0x18,%esp
 5cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d0:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5d3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5da:	00 
 5db:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5de:	89 44 24 04          	mov    %eax,0x4(%esp)
 5e2:	8b 45 08             	mov    0x8(%ebp),%eax
 5e5:	89 04 24             	mov    %eax,(%esp)
 5e8:	e8 1a ff ff ff       	call   507 <write>
}
 5ed:	c9                   	leave  
 5ee:	c3                   	ret    

000005ef <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ef:	55                   	push   %ebp
 5f0:	89 e5                	mov    %esp,%ebp
 5f2:	56                   	push   %esi
 5f3:	53                   	push   %ebx
 5f4:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5f7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 5fe:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 602:	74 17                	je     61b <printint+0x2c>
 604:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 608:	79 11                	jns    61b <printint+0x2c>
    neg = 1;
 60a:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 611:	8b 45 0c             	mov    0xc(%ebp),%eax
 614:	f7 d8                	neg    %eax
 616:	89 45 ec             	mov    %eax,-0x14(%ebp)
 619:	eb 06                	jmp    621 <printint+0x32>
  } else {
    x = xx;
 61b:	8b 45 0c             	mov    0xc(%ebp),%eax
 61e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 621:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 628:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 62b:	8d 41 01             	lea    0x1(%ecx),%eax
 62e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 631:	8b 5d 10             	mov    0x10(%ebp),%ebx
 634:	8b 45 ec             	mov    -0x14(%ebp),%eax
 637:	ba 00 00 00 00       	mov    $0x0,%edx
 63c:	f7 f3                	div    %ebx
 63e:	89 d0                	mov    %edx,%eax
 640:	0f b6 80 42 0d 00 00 	movzbl 0xd42(%eax),%eax
 647:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 64b:	8b 75 10             	mov    0x10(%ebp),%esi
 64e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 651:	ba 00 00 00 00       	mov    $0x0,%edx
 656:	f7 f6                	div    %esi
 658:	89 45 ec             	mov    %eax,-0x14(%ebp)
 65b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 65f:	75 c7                	jne    628 <printint+0x39>
  if(neg)
 661:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 665:	74 10                	je     677 <printint+0x88>
    buf[i++] = '-';
 667:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66a:	8d 50 01             	lea    0x1(%eax),%edx
 66d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 670:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 675:	eb 1f                	jmp    696 <printint+0xa7>
 677:	eb 1d                	jmp    696 <printint+0xa7>
    putc(fd, buf[i]);
 679:	8d 55 dc             	lea    -0x24(%ebp),%edx
 67c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67f:	01 d0                	add    %edx,%eax
 681:	0f b6 00             	movzbl (%eax),%eax
 684:	0f be c0             	movsbl %al,%eax
 687:	89 44 24 04          	mov    %eax,0x4(%esp)
 68b:	8b 45 08             	mov    0x8(%ebp),%eax
 68e:	89 04 24             	mov    %eax,(%esp)
 691:	e8 31 ff ff ff       	call   5c7 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 696:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 69a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69e:	79 d9                	jns    679 <printint+0x8a>
    putc(fd, buf[i]);
}
 6a0:	83 c4 30             	add    $0x30,%esp
 6a3:	5b                   	pop    %ebx
 6a4:	5e                   	pop    %esi
 6a5:	5d                   	pop    %ebp
 6a6:	c3                   	ret    

000006a7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 6a7:	55                   	push   %ebp
 6a8:	89 e5                	mov    %esp,%ebp
 6aa:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ad:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6b4:	8d 45 0c             	lea    0xc(%ebp),%eax
 6b7:	83 c0 04             	add    $0x4,%eax
 6ba:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6bd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6c4:	e9 7c 01 00 00       	jmp    845 <printf+0x19e>
    c = fmt[i] & 0xff;
 6c9:	8b 55 0c             	mov    0xc(%ebp),%edx
 6cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6cf:	01 d0                	add    %edx,%eax
 6d1:	0f b6 00             	movzbl (%eax),%eax
 6d4:	0f be c0             	movsbl %al,%eax
 6d7:	25 ff 00 00 00       	and    $0xff,%eax
 6dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e3:	75 2c                	jne    711 <printf+0x6a>
      if(c == '%'){
 6e5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6e9:	75 0c                	jne    6f7 <printf+0x50>
        state = '%';
 6eb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6f2:	e9 4a 01 00 00       	jmp    841 <printf+0x19a>
      } else {
        putc(fd, c);
 6f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6fa:	0f be c0             	movsbl %al,%eax
 6fd:	89 44 24 04          	mov    %eax,0x4(%esp)
 701:	8b 45 08             	mov    0x8(%ebp),%eax
 704:	89 04 24             	mov    %eax,(%esp)
 707:	e8 bb fe ff ff       	call   5c7 <putc>
 70c:	e9 30 01 00 00       	jmp    841 <printf+0x19a>
      }
    } else if(state == '%'){
 711:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 715:	0f 85 26 01 00 00    	jne    841 <printf+0x19a>
      if(c == 'd'){
 71b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 71f:	75 2d                	jne    74e <printf+0xa7>
        printint(fd, *ap, 10, 1);
 721:	8b 45 e8             	mov    -0x18(%ebp),%eax
 724:	8b 00                	mov    (%eax),%eax
 726:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 72d:	00 
 72e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 735:	00 
 736:	89 44 24 04          	mov    %eax,0x4(%esp)
 73a:	8b 45 08             	mov    0x8(%ebp),%eax
 73d:	89 04 24             	mov    %eax,(%esp)
 740:	e8 aa fe ff ff       	call   5ef <printint>
        ap++;
 745:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 749:	e9 ec 00 00 00       	jmp    83a <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 74e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 752:	74 06                	je     75a <printf+0xb3>
 754:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 758:	75 2d                	jne    787 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 75a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 75d:	8b 00                	mov    (%eax),%eax
 75f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 766:	00 
 767:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 76e:	00 
 76f:	89 44 24 04          	mov    %eax,0x4(%esp)
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	89 04 24             	mov    %eax,(%esp)
 779:	e8 71 fe ff ff       	call   5ef <printint>
        ap++;
 77e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 782:	e9 b3 00 00 00       	jmp    83a <printf+0x193>
      } else if(c == 's'){
 787:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 78b:	75 45                	jne    7d2 <printf+0x12b>
        s = (char*)*ap;
 78d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 795:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 799:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79d:	75 09                	jne    7a8 <printf+0x101>
          s = "(null)";
 79f:	c7 45 f4 9a 0a 00 00 	movl   $0xa9a,-0xc(%ebp)
        while(*s != 0){
 7a6:	eb 1e                	jmp    7c6 <printf+0x11f>
 7a8:	eb 1c                	jmp    7c6 <printf+0x11f>
          putc(fd, *s);
 7aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ad:	0f b6 00             	movzbl (%eax),%eax
 7b0:	0f be c0             	movsbl %al,%eax
 7b3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ba:	89 04 24             	mov    %eax,(%esp)
 7bd:	e8 05 fe ff ff       	call   5c7 <putc>
          s++;
 7c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	0f b6 00             	movzbl (%eax),%eax
 7cc:	84 c0                	test   %al,%al
 7ce:	75 da                	jne    7aa <printf+0x103>
 7d0:	eb 68                	jmp    83a <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7d2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7d6:	75 1d                	jne    7f5 <printf+0x14e>
        putc(fd, *ap);
 7d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	0f be c0             	movsbl %al,%eax
 7e0:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e4:	8b 45 08             	mov    0x8(%ebp),%eax
 7e7:	89 04 24             	mov    %eax,(%esp)
 7ea:	e8 d8 fd ff ff       	call   5c7 <putc>
        ap++;
 7ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f3:	eb 45                	jmp    83a <printf+0x193>
      } else if(c == '%'){
 7f5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7f9:	75 17                	jne    812 <printf+0x16b>
        putc(fd, c);
 7fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7fe:	0f be c0             	movsbl %al,%eax
 801:	89 44 24 04          	mov    %eax,0x4(%esp)
 805:	8b 45 08             	mov    0x8(%ebp),%eax
 808:	89 04 24             	mov    %eax,(%esp)
 80b:	e8 b7 fd ff ff       	call   5c7 <putc>
 810:	eb 28                	jmp    83a <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 812:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 819:	00 
 81a:	8b 45 08             	mov    0x8(%ebp),%eax
 81d:	89 04 24             	mov    %eax,(%esp)
 820:	e8 a2 fd ff ff       	call   5c7 <putc>
        putc(fd, c);
 825:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 828:	0f be c0             	movsbl %al,%eax
 82b:	89 44 24 04          	mov    %eax,0x4(%esp)
 82f:	8b 45 08             	mov    0x8(%ebp),%eax
 832:	89 04 24             	mov    %eax,(%esp)
 835:	e8 8d fd ff ff       	call   5c7 <putc>
      }
      state = 0;
 83a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 841:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 845:	8b 55 0c             	mov    0xc(%ebp),%edx
 848:	8b 45 f0             	mov    -0x10(%ebp),%eax
 84b:	01 d0                	add    %edx,%eax
 84d:	0f b6 00             	movzbl (%eax),%eax
 850:	84 c0                	test   %al,%al
 852:	0f 85 71 fe ff ff    	jne    6c9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 858:	c9                   	leave  
 859:	c3                   	ret    

0000085a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85a:	55                   	push   %ebp
 85b:	89 e5                	mov    %esp,%ebp
 85d:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 860:	8b 45 08             	mov    0x8(%ebp),%eax
 863:	83 e8 08             	sub    $0x8,%eax
 866:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 869:	a1 5c 0d 00 00       	mov    0xd5c,%eax
 86e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 871:	eb 24                	jmp    897 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 87b:	77 12                	ja     88f <free+0x35>
 87d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 880:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 883:	77 24                	ja     8a9 <free+0x4f>
 885:	8b 45 fc             	mov    -0x4(%ebp),%eax
 888:	8b 00                	mov    (%eax),%eax
 88a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 88d:	77 1a                	ja     8a9 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 892:	8b 00                	mov    (%eax),%eax
 894:	89 45 fc             	mov    %eax,-0x4(%ebp)
 897:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 89d:	76 d4                	jbe    873 <free+0x19>
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	8b 00                	mov    (%eax),%eax
 8a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8a7:	76 ca                	jbe    873 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 8a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ac:	8b 40 04             	mov    0x4(%eax),%eax
 8af:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8b9:	01 c2                	add    %eax,%edx
 8bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8be:	8b 00                	mov    (%eax),%eax
 8c0:	39 c2                	cmp    %eax,%edx
 8c2:	75 24                	jne    8e8 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 8c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c7:	8b 50 04             	mov    0x4(%eax),%edx
 8ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cd:	8b 00                	mov    (%eax),%eax
 8cf:	8b 40 04             	mov    0x4(%eax),%eax
 8d2:	01 c2                	add    %eax,%edx
 8d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d7:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dd:	8b 00                	mov    (%eax),%eax
 8df:	8b 10                	mov    (%eax),%edx
 8e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8e4:	89 10                	mov    %edx,(%eax)
 8e6:	eb 0a                	jmp    8f2 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 8e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8eb:	8b 10                	mov    (%eax),%edx
 8ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f0:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	8b 40 04             	mov    0x4(%eax),%eax
 8f8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 902:	01 d0                	add    %edx,%eax
 904:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 907:	75 20                	jne    929 <free+0xcf>
    p->s.size += bp->s.size;
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 50 04             	mov    0x4(%eax),%edx
 90f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 912:	8b 40 04             	mov    0x4(%eax),%eax
 915:	01 c2                	add    %eax,%edx
 917:	8b 45 fc             	mov    -0x4(%ebp),%eax
 91a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 91d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 920:	8b 10                	mov    (%eax),%edx
 922:	8b 45 fc             	mov    -0x4(%ebp),%eax
 925:	89 10                	mov    %edx,(%eax)
 927:	eb 08                	jmp    931 <free+0xd7>
  } else
    p->s.ptr = bp;
 929:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 92f:	89 10                	mov    %edx,(%eax)
  freep = p;
 931:	8b 45 fc             	mov    -0x4(%ebp),%eax
 934:	a3 5c 0d 00 00       	mov    %eax,0xd5c
}
 939:	c9                   	leave  
 93a:	c3                   	ret    

0000093b <morecore>:

static Header*
morecore(uint nu)
{
 93b:	55                   	push   %ebp
 93c:	89 e5                	mov    %esp,%ebp
 93e:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 941:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 948:	77 07                	ja     951 <morecore+0x16>
    nu = 4096;
 94a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 951:	8b 45 08             	mov    0x8(%ebp),%eax
 954:	c1 e0 03             	shl    $0x3,%eax
 957:	89 04 24             	mov    %eax,(%esp)
 95a:	e8 10 fc ff ff       	call   56f <sbrk>
 95f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 962:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 966:	75 07                	jne    96f <morecore+0x34>
    return 0;
 968:	b8 00 00 00 00       	mov    $0x0,%eax
 96d:	eb 22                	jmp    991 <morecore+0x56>
  hp = (Header*)p;
 96f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 972:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 975:	8b 45 f0             	mov    -0x10(%ebp),%eax
 978:	8b 55 08             	mov    0x8(%ebp),%edx
 97b:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 97e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 981:	83 c0 08             	add    $0x8,%eax
 984:	89 04 24             	mov    %eax,(%esp)
 987:	e8 ce fe ff ff       	call   85a <free>
  return freep;
 98c:	a1 5c 0d 00 00       	mov    0xd5c,%eax
}
 991:	c9                   	leave  
 992:	c3                   	ret    

00000993 <malloc>:

void*
malloc(uint nbytes)
{
 993:	55                   	push   %ebp
 994:	89 e5                	mov    %esp,%ebp
 996:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 999:	8b 45 08             	mov    0x8(%ebp),%eax
 99c:	83 c0 07             	add    $0x7,%eax
 99f:	c1 e8 03             	shr    $0x3,%eax
 9a2:	83 c0 01             	add    $0x1,%eax
 9a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 9a8:	a1 5c 0d 00 00       	mov    0xd5c,%eax
 9ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9b4:	75 23                	jne    9d9 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 9b6:	c7 45 f0 54 0d 00 00 	movl   $0xd54,-0x10(%ebp)
 9bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9c0:	a3 5c 0d 00 00       	mov    %eax,0xd5c
 9c5:	a1 5c 0d 00 00       	mov    0xd5c,%eax
 9ca:	a3 54 0d 00 00       	mov    %eax,0xd54
    base.s.size = 0;
 9cf:	c7 05 58 0d 00 00 00 	movl   $0x0,0xd58
 9d6:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9dc:	8b 00                	mov    (%eax),%eax
 9de:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e4:	8b 40 04             	mov    0x4(%eax),%eax
 9e7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9ea:	72 4d                	jb     a39 <malloc+0xa6>
      if(p->s.size == nunits)
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 40 04             	mov    0x4(%eax),%eax
 9f2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 9f5:	75 0c                	jne    a03 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 9f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fa:	8b 10                	mov    (%eax),%edx
 9fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ff:	89 10                	mov    %edx,(%eax)
 a01:	eb 26                	jmp    a29 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a06:	8b 40 04             	mov    0x4(%eax),%eax
 a09:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a0c:	89 c2                	mov    %eax,%edx
 a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a11:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a17:	8b 40 04             	mov    0x4(%eax),%eax
 a1a:	c1 e0 03             	shl    $0x3,%eax
 a1d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a23:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a26:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2c:	a3 5c 0d 00 00       	mov    %eax,0xd5c
      return (void*)(p + 1);
 a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a34:	83 c0 08             	add    $0x8,%eax
 a37:	eb 38                	jmp    a71 <malloc+0xde>
    }
    if(p == freep)
 a39:	a1 5c 0d 00 00       	mov    0xd5c,%eax
 a3e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a41:	75 1b                	jne    a5e <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 a43:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a46:	89 04 24             	mov    %eax,(%esp)
 a49:	e8 ed fe ff ff       	call   93b <morecore>
 a4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a55:	75 07                	jne    a5e <malloc+0xcb>
        return 0;
 a57:	b8 00 00 00 00       	mov    $0x0,%eax
 a5c:	eb 13                	jmp    a71 <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a67:	8b 00                	mov    (%eax),%eax
 a69:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 a6c:	e9 70 ff ff ff       	jmp    9e1 <malloc+0x4e>
}
 a71:	c9                   	leave  
 a72:	c3                   	ret    
