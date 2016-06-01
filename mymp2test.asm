
_mymp2test:     file format elf32-i386


Disassembly of section .text:

00000000 <tmain>:
#include "types.h"
#include "user.h"

void tmain(void* arg){
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp

	//printf(1, "argument: %d\n", arg);
	int i = 0;
   6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	i++;
   d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	printf(1, "child %d\n", i);
  11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  14:	89 44 24 08          	mov    %eax,0x8(%esp)
  18:	c7 44 24 04 e0 0a 00 	movl   $0xae0,0x4(%esp)
  1f:	00 
  20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  27:	e8 e5 06 00 00       	call   711 <printf>
	exit();
  2c:	e8 20 05 00 00       	call   551 <exit>

00000031 <producer>:
//int* arg;
uint* stack;
uint* stack1;
int  mutex;

void producer(void* arg){
  31:	55                   	push   %ebp
  32:	89 e5                	mov    %esp,%ebp
  34:	83 ec 28             	sub    $0x28,%esp
	//printf(1,"producer argggg has : %d\n", arg[0]);
	int *buffer = (int *)arg;
  37:	8b 45 08             	mov    0x8(%ebp),%eax
  3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i;
	for(i = 1; i < 10;i++){
  3d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  44:	eb 67                	jmp    ad <producer+0x7c>
		mtx_lock(mutex);
  46:	a1 9c 0e 00 00       	mov    0xe9c,%eax
  4b:	89 04 24             	mov    %eax,(%esp)
  4e:	e8 ce 05 00 00       	call   621 <mtx_lock>
		//printf(1,"Producer before : %d\n", buffer[i]);
		buffer[i] = i;
  53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  56:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  60:	01 c2                	add    %eax,%edx
  62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  65:	89 02                	mov    %eax,(%edx)
		printf(1,"Producer put : %d\n", buffer[i]);
  67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  74:	01 d0                	add    %edx,%eax
  76:	8b 00                	mov    (%eax),%eax
  78:	89 44 24 08          	mov    %eax,0x8(%esp)
  7c:	c7 44 24 04 ea 0a 00 	movl   $0xaea,0x4(%esp)
  83:	00 
  84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8b:	e8 81 06 00 00       	call   711 <printf>
		mtx_unlock(mutex);
  90:	a1 9c 0e 00 00       	mov    0xe9c,%eax
  95:	89 04 24             	mov    %eax,(%esp)
  98:	e8 8c 05 00 00       	call   629 <mtx_unlock>

		sleep(10);
  9d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  a4:	e8 38 05 00 00       	call   5e1 <sleep>

void producer(void* arg){
	//printf(1,"producer argggg has : %d\n", arg[0]);
	int *buffer = (int *)arg;
	int i;
	for(i = 1; i < 10;i++){
  a9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  ad:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
  b1:	7e 93                	jle    46 <producer+0x15>
		mtx_unlock(mutex);

		sleep(10);

	}
	printf(1,"producer is done \n");
  b3:	c7 44 24 04 fd 0a 00 	movl   $0xafd,0x4(%esp)
  ba:	00 
  bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c2:	e8 4a 06 00 00       	call   711 <printf>
	exit();
  c7:	e8 85 04 00 00       	call   551 <exit>

000000cc <consumer>:

}

void consumer(void* arg){
  cc:	55                   	push   %ebp
  cd:	89 e5                	mov    %esp,%ebp
  cf:	83 ec 28             	sub    $0x28,%esp
	//printf(1,"consumer argggg has : %d\n", arg[0]);
	int *buffer = (int *)arg;
  d2:	8b 45 08             	mov    0x8(%ebp),%eax
  d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int j;
	mtx_lock(mutex);
  d8:	a1 9c 0e 00 00       	mov    0xe9c,%eax
  dd:	89 04 24             	mov    %eax,(%esp)
  e0:	e8 3c 05 00 00       	call   621 <mtx_lock>

	for(j = 1; j < 10;j++){
  e5:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  ec:	eb 58                	jmp    146 <consumer+0x7a>
		if(buffer[j] != 109){
  ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  fb:	01 d0                	add    %edx,%eax
  fd:	8b 00                	mov    (%eax),%eax
  ff:	83 f8 6d             	cmp    $0x6d,%eax
 102:	74 3e                	je     142 <consumer+0x76>
		   printf(1,"consumer has : %d\n", buffer[j]);
 104:	8b 45 f4             	mov    -0xc(%ebp),%eax
 107:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 10e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 111:	01 d0                	add    %edx,%eax
 113:	8b 00                	mov    (%eax),%eax
 115:	89 44 24 08          	mov    %eax,0x8(%esp)
 119:	c7 44 24 04 10 0b 00 	movl   $0xb10,0x4(%esp)
 120:	00 
 121:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 128:	e8 e4 05 00 00       	call   711 <printf>
		   buffer[j] = 109;
 12d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 130:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 137:	8b 45 f0             	mov    -0x10(%ebp),%eax
 13a:	01 d0                	add    %edx,%eax
 13c:	c7 00 6d 00 00 00    	movl   $0x6d,(%eax)
	//printf(1,"consumer argggg has : %d\n", arg[0]);
	int *buffer = (int *)arg;
	int j;
	mtx_lock(mutex);

	for(j = 1; j < 10;j++){
 142:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 146:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
 14a:	7e a2                	jle    ee <consumer+0x22>
		   buffer[j] = 109;
		   //printf(1,"consumer after: %d\n", buffer[j]);
		}	
	}	

	mtx_unlock(mutex);
 14c:	a1 9c 0e 00 00       	mov    0xe9c,%eax
 151:	89 04 24             	mov    %eax,(%esp)
 154:	e8 d0 04 00 00       	call   629 <mtx_unlock>
	printf(1,"consumer is done \n");
 159:	c7 44 24 04 23 0b 00 	movl   $0xb23,0x4(%esp)
 160:	00 
 161:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 168:	e8 a4 05 00 00       	call   711 <printf>
	sleep(10);
 16d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
 174:	e8 68 04 00 00       	call   5e1 <sleep>

	

	exit();
 179:	e8 d3 03 00 00       	call   551 <exit>

0000017e <main>:

}

int main(int argc, char *argv[])
{
 17e:	55                   	push   %ebp
 17f:	89 e5                	mov    %esp,%ebp
 181:	83 e4 f0             	and    $0xfffffff0,%esp
 184:	83 ec 20             	sub    $0x20,%esp
	//int j;
	mutex =mtx_create(0);
 187:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 18e:	e8 86 04 00 00       	call   619 <mtx_create>
 193:	a3 9c 0e 00 00       	mov    %eax,0xe9c
	char *arg ="mmmmmmmmmmmmmmmmmmmm";
 198:	c7 44 24 1c 36 0b 00 	movl   $0xb36,0x1c(%esp)
 19f:	00 
	//char arg[20] ="mmmmmmmmmmmmmmmmmmmm"
	//int* arg = (int*)malloc(10*sizeof(int *));
	//memset(arg, 20, 10*sizeof(int*));


	printf(1,"argggg inittttttttt %d\n", arg[0]);
 1a0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1a4:	0f b6 00             	movzbl (%eax),%eax
 1a7:	0f be c0             	movsbl %al,%eax
 1aa:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ae:	c7 44 24 04 4b 0b 00 	movl   $0xb4b,0x4(%esp)
 1b5:	00 
 1b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bd:	e8 4f 05 00 00       	call   711 <printf>
	printf(1,"argggg inittttttttt %d\n", arg[1]);
 1c2:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1c6:	83 c0 01             	add    $0x1,%eax
 1c9:	0f b6 00             	movzbl (%eax),%eax
 1cc:	0f be c0             	movsbl %al,%eax
 1cf:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d3:	c7 44 24 04 4b 0b 00 	movl   $0xb4b,0x4(%esp)
 1da:	00 
 1db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1e2:	e8 2a 05 00 00       	call   711 <printf>
	stack = (uint*)malloc(1024*sizeof(uint));
 1e7:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
 1ee:	e8 0a 08 00 00       	call   9fd <malloc>
 1f3:	a3 98 0e 00 00       	mov    %eax,0xe98

	uint* r_stack = (uint*)0;
 1f8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
 1ff:	00 
		//int v = thread_create(tmain, (void*)stack, (void*)arg);
		// printf(1,"thread_create3 %d\n", v);
		// printf(1, "argumentttttt: %d\n", (char*)arg);


	int v =thread_create(*producer, (void*)stack, (void*)arg);	
 200:	a1 98 0e 00 00       	mov    0xe98,%eax
 205:	8b 54 24 1c          	mov    0x1c(%esp),%edx
 209:	89 54 24 08          	mov    %edx,0x8(%esp)
 20d:	89 44 24 04          	mov    %eax,0x4(%esp)
 211:	c7 04 24 31 00 00 00 	movl   $0x31,(%esp)
 218:	e8 ec 03 00 00       	call   609 <thread_create>
 21d:	89 44 24 18          	mov    %eax,0x18(%esp)

	thread_join((void **)&r_stack);
 221:	8d 44 24 10          	lea    0x10(%esp),%eax
 225:	89 04 24             	mov    %eax,(%esp)
 228:	e8 e4 03 00 00       	call   611 <thread_join>

	//}
	printf(1,"main pid = %d, producer thread pid = %d\n", getpid(), v);
 22d:	e8 9f 03 00 00       	call   5d1 <getpid>
 232:	8b 54 24 18          	mov    0x18(%esp),%edx
 236:	89 54 24 0c          	mov    %edx,0xc(%esp)
 23a:	89 44 24 08          	mov    %eax,0x8(%esp)
 23e:	c7 44 24 04 64 0b 00 	movl   $0xb64,0x4(%esp)
 245:	00 
 246:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 24d:	e8 bf 04 00 00       	call   711 <printf>
  	sleep(50);
 252:	c7 04 24 32 00 00 00 	movl   $0x32,(%esp)
 259:	e8 83 03 00 00       	call   5e1 <sleep>
	printf(1,"sssssssssssssss\n" );
 25e:	c7 44 24 04 8d 0b 00 	movl   $0xb8d,0x4(%esp)
 265:	00 
 266:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 26d:	e8 9f 04 00 00       	call   711 <printf>

	int x = thread_create(consumer, (void*)stack, (void*)arg);
 272:	a1 98 0e 00 00       	mov    0xe98,%eax
 277:	8b 54 24 1c          	mov    0x1c(%esp),%edx
 27b:	89 54 24 08          	mov    %edx,0x8(%esp)
 27f:	89 44 24 04          	mov    %eax,0x4(%esp)
 283:	c7 04 24 cc 00 00 00 	movl   $0xcc,(%esp)
 28a:	e8 7a 03 00 00       	call   609 <thread_create>
 28f:	89 44 24 14          	mov    %eax,0x14(%esp)
	printf(1,"main pid  = %d, consumer pid pid = %d\n", getpid(), x);	
 293:	e8 39 03 00 00       	call   5d1 <getpid>
 298:	8b 54 24 14          	mov    0x14(%esp),%edx
 29c:	89 54 24 0c          	mov    %edx,0xc(%esp)
 2a0:	89 44 24 08          	mov    %eax,0x8(%esp)
 2a4:	c7 44 24 04 a0 0b 00 	movl   $0xba0,0x4(%esp)
 2ab:	00 
 2ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2b3:	e8 59 04 00 00       	call   711 <printf>

	thread_join((void **)&r_stack);
 2b8:	8d 44 24 10          	lea    0x10(%esp),%eax
 2bc:	89 04 24             	mov    %eax,(%esp)
 2bf:	e8 4d 03 00 00       	call   611 <thread_join>



	printf(1,"end of main \n" );
 2c4:	c7 44 24 04 c7 0b 00 	movl   $0xbc7,0x4(%esp)
 2cb:	00 
 2cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2d3:	e8 39 04 00 00       	call   711 <printf>

	//free(stack);
	free(r_stack);
 2d8:	8b 44 24 10          	mov    0x10(%esp),%eax
 2dc:	89 04 24             	mov    %eax,(%esp)
 2df:	e8 e0 05 00 00       	call   8c4 <free>
	//printf(1,"thread_join return value%d\n", r);
	exit();
 2e4:	e8 68 02 00 00       	call   551 <exit>

000002e9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2e9:	55                   	push   %ebp
 2ea:	89 e5                	mov    %esp,%ebp
 2ec:	57                   	push   %edi
 2ed:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2f1:	8b 55 10             	mov    0x10(%ebp),%edx
 2f4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f7:	89 cb                	mov    %ecx,%ebx
 2f9:	89 df                	mov    %ebx,%edi
 2fb:	89 d1                	mov    %edx,%ecx
 2fd:	fc                   	cld    
 2fe:	f3 aa                	rep stos %al,%es:(%edi)
 300:	89 ca                	mov    %ecx,%edx
 302:	89 fb                	mov    %edi,%ebx
 304:	89 5d 08             	mov    %ebx,0x8(%ebp)
 307:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 30a:	5b                   	pop    %ebx
 30b:	5f                   	pop    %edi
 30c:	5d                   	pop    %ebp
 30d:	c3                   	ret    

0000030e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 30e:	55                   	push   %ebp
 30f:	89 e5                	mov    %esp,%ebp
 311:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 314:	8b 45 08             	mov    0x8(%ebp),%eax
 317:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 31a:	90                   	nop
 31b:	8b 45 08             	mov    0x8(%ebp),%eax
 31e:	8d 50 01             	lea    0x1(%eax),%edx
 321:	89 55 08             	mov    %edx,0x8(%ebp)
 324:	8b 55 0c             	mov    0xc(%ebp),%edx
 327:	8d 4a 01             	lea    0x1(%edx),%ecx
 32a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 32d:	0f b6 12             	movzbl (%edx),%edx
 330:	88 10                	mov    %dl,(%eax)
 332:	0f b6 00             	movzbl (%eax),%eax
 335:	84 c0                	test   %al,%al
 337:	75 e2                	jne    31b <strcpy+0xd>
    ;
  return os;
 339:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 33c:	c9                   	leave  
 33d:	c3                   	ret    

0000033e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 33e:	55                   	push   %ebp
 33f:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 341:	eb 08                	jmp    34b <strcmp+0xd>
    p++, q++;
 343:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 347:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	84 c0                	test   %al,%al
 353:	74 10                	je     365 <strcmp+0x27>
 355:	8b 45 08             	mov    0x8(%ebp),%eax
 358:	0f b6 10             	movzbl (%eax),%edx
 35b:	8b 45 0c             	mov    0xc(%ebp),%eax
 35e:	0f b6 00             	movzbl (%eax),%eax
 361:	38 c2                	cmp    %al,%dl
 363:	74 de                	je     343 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 365:	8b 45 08             	mov    0x8(%ebp),%eax
 368:	0f b6 00             	movzbl (%eax),%eax
 36b:	0f b6 d0             	movzbl %al,%edx
 36e:	8b 45 0c             	mov    0xc(%ebp),%eax
 371:	0f b6 00             	movzbl (%eax),%eax
 374:	0f b6 c0             	movzbl %al,%eax
 377:	29 c2                	sub    %eax,%edx
 379:	89 d0                	mov    %edx,%eax
}
 37b:	5d                   	pop    %ebp
 37c:	c3                   	ret    

0000037d <strlen>:

uint
strlen(char *s)
{
 37d:	55                   	push   %ebp
 37e:	89 e5                	mov    %esp,%ebp
 380:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 383:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 38a:	eb 04                	jmp    390 <strlen+0x13>
 38c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 390:	8b 55 fc             	mov    -0x4(%ebp),%edx
 393:	8b 45 08             	mov    0x8(%ebp),%eax
 396:	01 d0                	add    %edx,%eax
 398:	0f b6 00             	movzbl (%eax),%eax
 39b:	84 c0                	test   %al,%al
 39d:	75 ed                	jne    38c <strlen+0xf>
    ;
  return n;
 39f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a2:	c9                   	leave  
 3a3:	c3                   	ret    

000003a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3a4:	55                   	push   %ebp
 3a5:	89 e5                	mov    %esp,%ebp
 3a7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 3aa:	8b 45 10             	mov    0x10(%ebp),%eax
 3ad:	89 44 24 08          	mov    %eax,0x8(%esp)
 3b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 3b8:	8b 45 08             	mov    0x8(%ebp),%eax
 3bb:	89 04 24             	mov    %eax,(%esp)
 3be:	e8 26 ff ff ff       	call   2e9 <stosb>
  return dst;
 3c3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3c6:	c9                   	leave  
 3c7:	c3                   	ret    

000003c8 <strchr>:

char*
strchr(const char *s, char c)
{
 3c8:	55                   	push   %ebp
 3c9:	89 e5                	mov    %esp,%ebp
 3cb:	83 ec 04             	sub    $0x4,%esp
 3ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3d4:	eb 14                	jmp    3ea <strchr+0x22>
    if(*s == c)
 3d6:	8b 45 08             	mov    0x8(%ebp),%eax
 3d9:	0f b6 00             	movzbl (%eax),%eax
 3dc:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3df:	75 05                	jne    3e6 <strchr+0x1e>
      return (char*)s;
 3e1:	8b 45 08             	mov    0x8(%ebp),%eax
 3e4:	eb 13                	jmp    3f9 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3ea:	8b 45 08             	mov    0x8(%ebp),%eax
 3ed:	0f b6 00             	movzbl (%eax),%eax
 3f0:	84 c0                	test   %al,%al
 3f2:	75 e2                	jne    3d6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3f9:	c9                   	leave  
 3fa:	c3                   	ret    

000003fb <gets>:

char*
gets(char *buf, int max)
{
 3fb:	55                   	push   %ebp
 3fc:	89 e5                	mov    %esp,%ebp
 3fe:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 408:	eb 4c                	jmp    456 <gets+0x5b>
    cc = read(0, &c, 1);
 40a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 411:	00 
 412:	8d 45 ef             	lea    -0x11(%ebp),%eax
 415:	89 44 24 04          	mov    %eax,0x4(%esp)
 419:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 420:	e8 44 01 00 00       	call   569 <read>
 425:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 428:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 42c:	7f 02                	jg     430 <gets+0x35>
      break;
 42e:	eb 31                	jmp    461 <gets+0x66>
    buf[i++] = c;
 430:	8b 45 f4             	mov    -0xc(%ebp),%eax
 433:	8d 50 01             	lea    0x1(%eax),%edx
 436:	89 55 f4             	mov    %edx,-0xc(%ebp)
 439:	89 c2                	mov    %eax,%edx
 43b:	8b 45 08             	mov    0x8(%ebp),%eax
 43e:	01 c2                	add    %eax,%edx
 440:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 444:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 446:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 44a:	3c 0a                	cmp    $0xa,%al
 44c:	74 13                	je     461 <gets+0x66>
 44e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 452:	3c 0d                	cmp    $0xd,%al
 454:	74 0b                	je     461 <gets+0x66>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 456:	8b 45 f4             	mov    -0xc(%ebp),%eax
 459:	83 c0 01             	add    $0x1,%eax
 45c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 45f:	7c a9                	jl     40a <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 461:	8b 55 f4             	mov    -0xc(%ebp),%edx
 464:	8b 45 08             	mov    0x8(%ebp),%eax
 467:	01 d0                	add    %edx,%eax
 469:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 46f:	c9                   	leave  
 470:	c3                   	ret    

00000471 <stat>:

int
stat(char *n, struct stat *st)
{
 471:	55                   	push   %ebp
 472:	89 e5                	mov    %esp,%ebp
 474:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 477:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 47e:	00 
 47f:	8b 45 08             	mov    0x8(%ebp),%eax
 482:	89 04 24             	mov    %eax,(%esp)
 485:	e8 07 01 00 00       	call   591 <open>
 48a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 48d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 491:	79 07                	jns    49a <stat+0x29>
    return -1;
 493:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 498:	eb 23                	jmp    4bd <stat+0x4c>
  r = fstat(fd, st);
 49a:	8b 45 0c             	mov    0xc(%ebp),%eax
 49d:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4a4:	89 04 24             	mov    %eax,(%esp)
 4a7:	e8 fd 00 00 00       	call   5a9 <fstat>
 4ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 4af:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b2:	89 04 24             	mov    %eax,(%esp)
 4b5:	e8 bf 00 00 00       	call   579 <close>
  return r;
 4ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 4bd:	c9                   	leave  
 4be:	c3                   	ret    

000004bf <atoi>:

int
atoi(const char *s)
{
 4bf:	55                   	push   %ebp
 4c0:	89 e5                	mov    %esp,%ebp
 4c2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 4c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4cc:	eb 25                	jmp    4f3 <atoi+0x34>
    n = n*10 + *s++ - '0';
 4ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4d1:	89 d0                	mov    %edx,%eax
 4d3:	c1 e0 02             	shl    $0x2,%eax
 4d6:	01 d0                	add    %edx,%eax
 4d8:	01 c0                	add    %eax,%eax
 4da:	89 c1                	mov    %eax,%ecx
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	8d 50 01             	lea    0x1(%eax),%edx
 4e2:	89 55 08             	mov    %edx,0x8(%ebp)
 4e5:	0f b6 00             	movzbl (%eax),%eax
 4e8:	0f be c0             	movsbl %al,%eax
 4eb:	01 c8                	add    %ecx,%eax
 4ed:	83 e8 30             	sub    $0x30,%eax
 4f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	0f b6 00             	movzbl (%eax),%eax
 4f9:	3c 2f                	cmp    $0x2f,%al
 4fb:	7e 0a                	jle    507 <atoi+0x48>
 4fd:	8b 45 08             	mov    0x8(%ebp),%eax
 500:	0f b6 00             	movzbl (%eax),%eax
 503:	3c 39                	cmp    $0x39,%al
 505:	7e c7                	jle    4ce <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 507:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 50a:	c9                   	leave  
 50b:	c3                   	ret    

0000050c <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 50c:	55                   	push   %ebp
 50d:	89 e5                	mov    %esp,%ebp
 50f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 518:	8b 45 0c             	mov    0xc(%ebp),%eax
 51b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 51e:	eb 17                	jmp    537 <memmove+0x2b>
    *dst++ = *src++;
 520:	8b 45 fc             	mov    -0x4(%ebp),%eax
 523:	8d 50 01             	lea    0x1(%eax),%edx
 526:	89 55 fc             	mov    %edx,-0x4(%ebp)
 529:	8b 55 f8             	mov    -0x8(%ebp),%edx
 52c:	8d 4a 01             	lea    0x1(%edx),%ecx
 52f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 532:	0f b6 12             	movzbl (%edx),%edx
 535:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 537:	8b 45 10             	mov    0x10(%ebp),%eax
 53a:	8d 50 ff             	lea    -0x1(%eax),%edx
 53d:	89 55 10             	mov    %edx,0x10(%ebp)
 540:	85 c0                	test   %eax,%eax
 542:	7f dc                	jg     520 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 544:	8b 45 08             	mov    0x8(%ebp),%eax
}
 547:	c9                   	leave  
 548:	c3                   	ret    

00000549 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 549:	b8 01 00 00 00       	mov    $0x1,%eax
 54e:	cd 40                	int    $0x40
 550:	c3                   	ret    

00000551 <exit>:
SYSCALL(exit)
 551:	b8 02 00 00 00       	mov    $0x2,%eax
 556:	cd 40                	int    $0x40
 558:	c3                   	ret    

00000559 <wait>:
SYSCALL(wait)
 559:	b8 03 00 00 00       	mov    $0x3,%eax
 55e:	cd 40                	int    $0x40
 560:	c3                   	ret    

00000561 <pipe>:
SYSCALL(pipe)
 561:	b8 04 00 00 00       	mov    $0x4,%eax
 566:	cd 40                	int    $0x40
 568:	c3                   	ret    

00000569 <read>:
SYSCALL(read)
 569:	b8 05 00 00 00       	mov    $0x5,%eax
 56e:	cd 40                	int    $0x40
 570:	c3                   	ret    

00000571 <write>:
SYSCALL(write)
 571:	b8 10 00 00 00       	mov    $0x10,%eax
 576:	cd 40                	int    $0x40
 578:	c3                   	ret    

00000579 <close>:
SYSCALL(close)
 579:	b8 15 00 00 00       	mov    $0x15,%eax
 57e:	cd 40                	int    $0x40
 580:	c3                   	ret    

00000581 <kill>:
SYSCALL(kill)
 581:	b8 06 00 00 00       	mov    $0x6,%eax
 586:	cd 40                	int    $0x40
 588:	c3                   	ret    

00000589 <exec>:
SYSCALL(exec)
 589:	b8 07 00 00 00       	mov    $0x7,%eax
 58e:	cd 40                	int    $0x40
 590:	c3                   	ret    

00000591 <open>:
SYSCALL(open)
 591:	b8 0f 00 00 00       	mov    $0xf,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret    

00000599 <mknod>:
SYSCALL(mknod)
 599:	b8 11 00 00 00       	mov    $0x11,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret    

000005a1 <unlink>:
SYSCALL(unlink)
 5a1:	b8 12 00 00 00       	mov    $0x12,%eax
 5a6:	cd 40                	int    $0x40
 5a8:	c3                   	ret    

000005a9 <fstat>:
SYSCALL(fstat)
 5a9:	b8 08 00 00 00       	mov    $0x8,%eax
 5ae:	cd 40                	int    $0x40
 5b0:	c3                   	ret    

000005b1 <link>:
SYSCALL(link)
 5b1:	b8 13 00 00 00       	mov    $0x13,%eax
 5b6:	cd 40                	int    $0x40
 5b8:	c3                   	ret    

000005b9 <mkdir>:
SYSCALL(mkdir)
 5b9:	b8 14 00 00 00       	mov    $0x14,%eax
 5be:	cd 40                	int    $0x40
 5c0:	c3                   	ret    

000005c1 <chdir>:
SYSCALL(chdir)
 5c1:	b8 09 00 00 00       	mov    $0x9,%eax
 5c6:	cd 40                	int    $0x40
 5c8:	c3                   	ret    

000005c9 <dup>:
SYSCALL(dup)
 5c9:	b8 0a 00 00 00       	mov    $0xa,%eax
 5ce:	cd 40                	int    $0x40
 5d0:	c3                   	ret    

000005d1 <getpid>:
SYSCALL(getpid)
 5d1:	b8 0b 00 00 00       	mov    $0xb,%eax
 5d6:	cd 40                	int    $0x40
 5d8:	c3                   	ret    

000005d9 <sbrk>:
SYSCALL(sbrk)
 5d9:	b8 0c 00 00 00       	mov    $0xc,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret    

000005e1 <sleep>:
SYSCALL(sleep)
 5e1:	b8 0d 00 00 00       	mov    $0xd,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret    

000005e9 <uptime>:
SYSCALL(uptime)
 5e9:	b8 0e 00 00 00       	mov    $0xe,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret    

000005f1 <startBurst>:
SYSCALL(startBurst)
 5f1:	b8 16 00 00 00       	mov    $0x16,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret    

000005f9 <endBurst>:
SYSCALL(endBurst)
 5f9:	b8 17 00 00 00       	mov    $0x17,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret    

00000601 <print_bursts>:
SYSCALL(print_bursts)
 601:	b8 18 00 00 00       	mov    $0x18,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret    

00000609 <thread_create>:
SYSCALL(thread_create)
 609:	b8 19 00 00 00       	mov    $0x19,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret    

00000611 <thread_join>:
SYSCALL(thread_join)
 611:	b8 1a 00 00 00       	mov    $0x1a,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret    

00000619 <mtx_create>:
SYSCALL(mtx_create)
 619:	b8 1b 00 00 00       	mov    $0x1b,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret    

00000621 <mtx_lock>:
SYSCALL(mtx_lock)
 621:	b8 1c 00 00 00       	mov    $0x1c,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret    

00000629 <mtx_unlock>:
SYSCALL(mtx_unlock)
 629:	b8 1d 00 00 00       	mov    $0x1d,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret    

00000631 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 631:	55                   	push   %ebp
 632:	89 e5                	mov    %esp,%ebp
 634:	83 ec 18             	sub    $0x18,%esp
 637:	8b 45 0c             	mov    0xc(%ebp),%eax
 63a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 63d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 644:	00 
 645:	8d 45 f4             	lea    -0xc(%ebp),%eax
 648:	89 44 24 04          	mov    %eax,0x4(%esp)
 64c:	8b 45 08             	mov    0x8(%ebp),%eax
 64f:	89 04 24             	mov    %eax,(%esp)
 652:	e8 1a ff ff ff       	call   571 <write>
}
 657:	c9                   	leave  
 658:	c3                   	ret    

00000659 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 659:	55                   	push   %ebp
 65a:	89 e5                	mov    %esp,%ebp
 65c:	56                   	push   %esi
 65d:	53                   	push   %ebx
 65e:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 661:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 668:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 66c:	74 17                	je     685 <printint+0x2c>
 66e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 672:	79 11                	jns    685 <printint+0x2c>
    neg = 1;
 674:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 67b:	8b 45 0c             	mov    0xc(%ebp),%eax
 67e:	f7 d8                	neg    %eax
 680:	89 45 ec             	mov    %eax,-0x14(%ebp)
 683:	eb 06                	jmp    68b <printint+0x32>
  } else {
    x = xx;
 685:	8b 45 0c             	mov    0xc(%ebp),%eax
 688:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 68b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 692:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 695:	8d 41 01             	lea    0x1(%ecx),%eax
 698:	89 45 f4             	mov    %eax,-0xc(%ebp)
 69b:	8b 5d 10             	mov    0x10(%ebp),%ebx
 69e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6a1:	ba 00 00 00 00       	mov    $0x0,%edx
 6a6:	f7 f3                	div    %ebx
 6a8:	89 d0                	mov    %edx,%eax
 6aa:	0f b6 80 74 0e 00 00 	movzbl 0xe74(%eax),%eax
 6b1:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6b5:	8b 75 10             	mov    0x10(%ebp),%esi
 6b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6bb:	ba 00 00 00 00       	mov    $0x0,%edx
 6c0:	f7 f6                	div    %esi
 6c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6c9:	75 c7                	jne    692 <printint+0x39>
  if(neg)
 6cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6cf:	74 10                	je     6e1 <printint+0x88>
    buf[i++] = '-';
 6d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d4:	8d 50 01             	lea    0x1(%eax),%edx
 6d7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 6da:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 6df:	eb 1f                	jmp    700 <printint+0xa7>
 6e1:	eb 1d                	jmp    700 <printint+0xa7>
    putc(fd, buf[i]);
 6e3:	8d 55 dc             	lea    -0x24(%ebp),%edx
 6e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e9:	01 d0                	add    %edx,%eax
 6eb:	0f b6 00             	movzbl (%eax),%eax
 6ee:	0f be c0             	movsbl %al,%eax
 6f1:	89 44 24 04          	mov    %eax,0x4(%esp)
 6f5:	8b 45 08             	mov    0x8(%ebp),%eax
 6f8:	89 04 24             	mov    %eax,(%esp)
 6fb:	e8 31 ff ff ff       	call   631 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 700:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 704:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 708:	79 d9                	jns    6e3 <printint+0x8a>
    putc(fd, buf[i]);
}
 70a:	83 c4 30             	add    $0x30,%esp
 70d:	5b                   	pop    %ebx
 70e:	5e                   	pop    %esi
 70f:	5d                   	pop    %ebp
 710:	c3                   	ret    

00000711 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 711:	55                   	push   %ebp
 712:	89 e5                	mov    %esp,%ebp
 714:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 717:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 71e:	8d 45 0c             	lea    0xc(%ebp),%eax
 721:	83 c0 04             	add    $0x4,%eax
 724:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 727:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 72e:	e9 7c 01 00 00       	jmp    8af <printf+0x19e>
    c = fmt[i] & 0xff;
 733:	8b 55 0c             	mov    0xc(%ebp),%edx
 736:	8b 45 f0             	mov    -0x10(%ebp),%eax
 739:	01 d0                	add    %edx,%eax
 73b:	0f b6 00             	movzbl (%eax),%eax
 73e:	0f be c0             	movsbl %al,%eax
 741:	25 ff 00 00 00       	and    $0xff,%eax
 746:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 749:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 74d:	75 2c                	jne    77b <printf+0x6a>
      if(c == '%'){
 74f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 753:	75 0c                	jne    761 <printf+0x50>
        state = '%';
 755:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 75c:	e9 4a 01 00 00       	jmp    8ab <printf+0x19a>
      } else {
        putc(fd, c);
 761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 764:	0f be c0             	movsbl %al,%eax
 767:	89 44 24 04          	mov    %eax,0x4(%esp)
 76b:	8b 45 08             	mov    0x8(%ebp),%eax
 76e:	89 04 24             	mov    %eax,(%esp)
 771:	e8 bb fe ff ff       	call   631 <putc>
 776:	e9 30 01 00 00       	jmp    8ab <printf+0x19a>
      }
    } else if(state == '%'){
 77b:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 77f:	0f 85 26 01 00 00    	jne    8ab <printf+0x19a>
      if(c == 'd'){
 785:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 789:	75 2d                	jne    7b8 <printf+0xa7>
        printint(fd, *ap, 10, 1);
 78b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 797:	00 
 798:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 79f:	00 
 7a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a4:	8b 45 08             	mov    0x8(%ebp),%eax
 7a7:	89 04 24             	mov    %eax,(%esp)
 7aa:	e8 aa fe ff ff       	call   659 <printint>
        ap++;
 7af:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7b3:	e9 ec 00 00 00       	jmp    8a4 <printf+0x193>
      } else if(c == 'x' || c == 'p'){
 7b8:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7bc:	74 06                	je     7c4 <printf+0xb3>
 7be:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7c2:	75 2d                	jne    7f1 <printf+0xe0>
        printint(fd, *ap, 16, 0);
 7c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c7:	8b 00                	mov    (%eax),%eax
 7c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 7d0:	00 
 7d1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 7d8:	00 
 7d9:	89 44 24 04          	mov    %eax,0x4(%esp)
 7dd:	8b 45 08             	mov    0x8(%ebp),%eax
 7e0:	89 04 24             	mov    %eax,(%esp)
 7e3:	e8 71 fe ff ff       	call   659 <printint>
        ap++;
 7e8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7ec:	e9 b3 00 00 00       	jmp    8a4 <printf+0x193>
      } else if(c == 's'){
 7f1:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 7f5:	75 45                	jne    83c <printf+0x12b>
        s = (char*)*ap;
 7f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7fa:	8b 00                	mov    (%eax),%eax
 7fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 7ff:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 803:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 807:	75 09                	jne    812 <printf+0x101>
          s = "(null)";
 809:	c7 45 f4 d5 0b 00 00 	movl   $0xbd5,-0xc(%ebp)
        while(*s != 0){
 810:	eb 1e                	jmp    830 <printf+0x11f>
 812:	eb 1c                	jmp    830 <printf+0x11f>
          putc(fd, *s);
 814:	8b 45 f4             	mov    -0xc(%ebp),%eax
 817:	0f b6 00             	movzbl (%eax),%eax
 81a:	0f be c0             	movsbl %al,%eax
 81d:	89 44 24 04          	mov    %eax,0x4(%esp)
 821:	8b 45 08             	mov    0x8(%ebp),%eax
 824:	89 04 24             	mov    %eax,(%esp)
 827:	e8 05 fe ff ff       	call   631 <putc>
          s++;
 82c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	0f b6 00             	movzbl (%eax),%eax
 836:	84 c0                	test   %al,%al
 838:	75 da                	jne    814 <printf+0x103>
 83a:	eb 68                	jmp    8a4 <printf+0x193>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 83c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 840:	75 1d                	jne    85f <printf+0x14e>
        putc(fd, *ap);
 842:	8b 45 e8             	mov    -0x18(%ebp),%eax
 845:	8b 00                	mov    (%eax),%eax
 847:	0f be c0             	movsbl %al,%eax
 84a:	89 44 24 04          	mov    %eax,0x4(%esp)
 84e:	8b 45 08             	mov    0x8(%ebp),%eax
 851:	89 04 24             	mov    %eax,(%esp)
 854:	e8 d8 fd ff ff       	call   631 <putc>
        ap++;
 859:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 85d:	eb 45                	jmp    8a4 <printf+0x193>
      } else if(c == '%'){
 85f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 863:	75 17                	jne    87c <printf+0x16b>
        putc(fd, c);
 865:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 868:	0f be c0             	movsbl %al,%eax
 86b:	89 44 24 04          	mov    %eax,0x4(%esp)
 86f:	8b 45 08             	mov    0x8(%ebp),%eax
 872:	89 04 24             	mov    %eax,(%esp)
 875:	e8 b7 fd ff ff       	call   631 <putc>
 87a:	eb 28                	jmp    8a4 <printf+0x193>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 87c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 883:	00 
 884:	8b 45 08             	mov    0x8(%ebp),%eax
 887:	89 04 24             	mov    %eax,(%esp)
 88a:	e8 a2 fd ff ff       	call   631 <putc>
        putc(fd, c);
 88f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 892:	0f be c0             	movsbl %al,%eax
 895:	89 44 24 04          	mov    %eax,0x4(%esp)
 899:	8b 45 08             	mov    0x8(%ebp),%eax
 89c:	89 04 24             	mov    %eax,(%esp)
 89f:	e8 8d fd ff ff       	call   631 <putc>
      }
      state = 0;
 8a4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8ab:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8af:	8b 55 0c             	mov    0xc(%ebp),%edx
 8b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8b5:	01 d0                	add    %edx,%eax
 8b7:	0f b6 00             	movzbl (%eax),%eax
 8ba:	84 c0                	test   %al,%al
 8bc:	0f 85 71 fe ff ff    	jne    733 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8c2:	c9                   	leave  
 8c3:	c3                   	ret    

000008c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8c4:	55                   	push   %ebp
 8c5:	89 e5                	mov    %esp,%ebp
 8c7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ca:	8b 45 08             	mov    0x8(%ebp),%eax
 8cd:	83 e8 08             	sub    $0x8,%eax
 8d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d3:	a1 90 0e 00 00       	mov    0xe90,%eax
 8d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8db:	eb 24                	jmp    901 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e0:	8b 00                	mov    (%eax),%eax
 8e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8e5:	77 12                	ja     8f9 <free+0x35>
 8e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ea:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ed:	77 24                	ja     913 <free+0x4f>
 8ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f2:	8b 00                	mov    (%eax),%eax
 8f4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8f7:	77 1a                	ja     913 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fc:	8b 00                	mov    (%eax),%eax
 8fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
 901:	8b 45 f8             	mov    -0x8(%ebp),%eax
 904:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 907:	76 d4                	jbe    8dd <free+0x19>
 909:	8b 45 fc             	mov    -0x4(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 911:	76 ca                	jbe    8dd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 913:	8b 45 f8             	mov    -0x8(%ebp),%eax
 916:	8b 40 04             	mov    0x4(%eax),%eax
 919:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 920:	8b 45 f8             	mov    -0x8(%ebp),%eax
 923:	01 c2                	add    %eax,%edx
 925:	8b 45 fc             	mov    -0x4(%ebp),%eax
 928:	8b 00                	mov    (%eax),%eax
 92a:	39 c2                	cmp    %eax,%edx
 92c:	75 24                	jne    952 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 92e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 931:	8b 50 04             	mov    0x4(%eax),%edx
 934:	8b 45 fc             	mov    -0x4(%ebp),%eax
 937:	8b 00                	mov    (%eax),%eax
 939:	8b 40 04             	mov    0x4(%eax),%eax
 93c:	01 c2                	add    %eax,%edx
 93e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 941:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 944:	8b 45 fc             	mov    -0x4(%ebp),%eax
 947:	8b 00                	mov    (%eax),%eax
 949:	8b 10                	mov    (%eax),%edx
 94b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 94e:	89 10                	mov    %edx,(%eax)
 950:	eb 0a                	jmp    95c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 952:	8b 45 fc             	mov    -0x4(%ebp),%eax
 955:	8b 10                	mov    (%eax),%edx
 957:	8b 45 f8             	mov    -0x8(%ebp),%eax
 95a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 95c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95f:	8b 40 04             	mov    0x4(%eax),%eax
 962:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	01 d0                	add    %edx,%eax
 96e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 971:	75 20                	jne    993 <free+0xcf>
    p->s.size += bp->s.size;
 973:	8b 45 fc             	mov    -0x4(%ebp),%eax
 976:	8b 50 04             	mov    0x4(%eax),%edx
 979:	8b 45 f8             	mov    -0x8(%ebp),%eax
 97c:	8b 40 04             	mov    0x4(%eax),%eax
 97f:	01 c2                	add    %eax,%edx
 981:	8b 45 fc             	mov    -0x4(%ebp),%eax
 984:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 987:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98a:	8b 10                	mov    (%eax),%edx
 98c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98f:	89 10                	mov    %edx,(%eax)
 991:	eb 08                	jmp    99b <free+0xd7>
  } else
    p->s.ptr = bp;
 993:	8b 45 fc             	mov    -0x4(%ebp),%eax
 996:	8b 55 f8             	mov    -0x8(%ebp),%edx
 999:	89 10                	mov    %edx,(%eax)
  freep = p;
 99b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99e:	a3 90 0e 00 00       	mov    %eax,0xe90
}
 9a3:	c9                   	leave  
 9a4:	c3                   	ret    

000009a5 <morecore>:

static Header*
morecore(uint nu)
{
 9a5:	55                   	push   %ebp
 9a6:	89 e5                	mov    %esp,%ebp
 9a8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9ab:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9b2:	77 07                	ja     9bb <morecore+0x16>
    nu = 4096;
 9b4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9bb:	8b 45 08             	mov    0x8(%ebp),%eax
 9be:	c1 e0 03             	shl    $0x3,%eax
 9c1:	89 04 24             	mov    %eax,(%esp)
 9c4:	e8 10 fc ff ff       	call   5d9 <sbrk>
 9c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9cc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9d0:	75 07                	jne    9d9 <morecore+0x34>
    return 0;
 9d2:	b8 00 00 00 00       	mov    $0x0,%eax
 9d7:	eb 22                	jmp    9fb <morecore+0x56>
  hp = (Header*)p;
 9d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9df:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9e2:	8b 55 08             	mov    0x8(%ebp),%edx
 9e5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9eb:	83 c0 08             	add    $0x8,%eax
 9ee:	89 04 24             	mov    %eax,(%esp)
 9f1:	e8 ce fe ff ff       	call   8c4 <free>
  return freep;
 9f6:	a1 90 0e 00 00       	mov    0xe90,%eax
}
 9fb:	c9                   	leave  
 9fc:	c3                   	ret    

000009fd <malloc>:

void*
malloc(uint nbytes)
{
 9fd:	55                   	push   %ebp
 9fe:	89 e5                	mov    %esp,%ebp
 a00:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a03:	8b 45 08             	mov    0x8(%ebp),%eax
 a06:	83 c0 07             	add    $0x7,%eax
 a09:	c1 e8 03             	shr    $0x3,%eax
 a0c:	83 c0 01             	add    $0x1,%eax
 a0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a12:	a1 90 0e 00 00       	mov    0xe90,%eax
 a17:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a1a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a1e:	75 23                	jne    a43 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a20:	c7 45 f0 88 0e 00 00 	movl   $0xe88,-0x10(%ebp)
 a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2a:	a3 90 0e 00 00       	mov    %eax,0xe90
 a2f:	a1 90 0e 00 00       	mov    0xe90,%eax
 a34:	a3 88 0e 00 00       	mov    %eax,0xe88
    base.s.size = 0;
 a39:	c7 05 8c 0e 00 00 00 	movl   $0x0,0xe8c
 a40:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a43:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a46:	8b 00                	mov    (%eax),%eax
 a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a4e:	8b 40 04             	mov    0x4(%eax),%eax
 a51:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a54:	72 4d                	jb     aa3 <malloc+0xa6>
      if(p->s.size == nunits)
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	8b 40 04             	mov    0x4(%eax),%eax
 a5c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a5f:	75 0c                	jne    a6d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a64:	8b 10                	mov    (%eax),%edx
 a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a69:	89 10                	mov    %edx,(%eax)
 a6b:	eb 26                	jmp    a93 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a70:	8b 40 04             	mov    0x4(%eax),%eax
 a73:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a76:	89 c2                	mov    %eax,%edx
 a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a81:	8b 40 04             	mov    0x4(%eax),%eax
 a84:	c1 e0 03             	shl    $0x3,%eax
 a87:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a90:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a96:	a3 90 0e 00 00       	mov    %eax,0xe90
      return (void*)(p + 1);
 a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9e:	83 c0 08             	add    $0x8,%eax
 aa1:	eb 38                	jmp    adb <malloc+0xde>
    }
    if(p == freep)
 aa3:	a1 90 0e 00 00       	mov    0xe90,%eax
 aa8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 aab:	75 1b                	jne    ac8 <malloc+0xcb>
      if((p = morecore(nunits)) == 0)
 aad:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ab0:	89 04 24             	mov    %eax,(%esp)
 ab3:	e8 ed fe ff ff       	call   9a5 <morecore>
 ab8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 abb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 abf:	75 07                	jne    ac8 <malloc+0xcb>
        return 0;
 ac1:	b8 00 00 00 00       	mov    $0x0,%eax
 ac6:	eb 13                	jmp    adb <malloc+0xde>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad1:	8b 00                	mov    (%eax),%eax
 ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ad6:	e9 70 ff ff ff       	jmp    a4b <malloc+0x4e>
}
 adb:	c9                   	leave  
 adc:	c3                   	ret    
