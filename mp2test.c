#include "types.h"
#include "user.h"

void tmain(void* arg){

	printf(1, "argument: %d\n", arg);
	int i = 0;
	i++;
	printf(1, "child %d\n", i);
	exit();
}




//int* arg;
uint* stack;

int main(int argc, char *argv[])
{
	//int j;
	char arg[10] ="maggie";
	stack = (uint*)malloc(32*sizeof(uint));
	uint* r_stack = (uint*)0;
	printf(1,"thread_create %d\n", stack);
	printf(1,"thread_create2 %d\n", &r_stack);
	//for( j= 0; j< 3; j++){
		int v = thread_create(tmain, (void*)stack, (void*)arg);
		printf(1,"thread_create3 %d\n", v);
		printf(1, "argumentttttt: %d\n", (char*)arg);
		

	//}
	printf(1,"start of sleep in main . main pid = %d, thread pid = %d\n", getpid(), v);
  	sleep(50);
	printf(1,"sssssssssssssss\n" );

	

	thread_join((void **)&r_stack);
	printf(1,"end of main \n" );

	free(stack);
	//printf(1,"thread_join return value%d\n", r);
	exit();
	return 0;
}


