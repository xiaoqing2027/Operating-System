#include "types.h"
#include "user.h"

void tmain(void* arg){

	//printf(1, "argument: %d\n", arg);
	int i = 0;
	i++;
	printf(1, "child %d\n", i);
	exit();
}


//int* arg;
uint* stack;
uint* stack1;
int  mutex;

void producer(void* arg){
	//printf(1,"producer argggg has : %d\n", arg[0]);
	int *buffer = (int *)arg;
	int i;
	for(i = 1; i < 10;i++){
		mtx_lock(mutex);
		//printf(1,"Producer before : %d\n", buffer[i]);
		buffer[i] = i;
		printf(1,"Producer put : %d\n", buffer[i]);
		mtx_unlock(mutex);

		sleep(10);

	}
	printf(1,"producer is done \n");
	exit();

}

void consumer(void* arg){
	//printf(1,"consumer argggg has : %d\n", arg[0]);
	int *buffer = (int *)arg;
	int j;
	mtx_lock(mutex);

	for(j = 1; j < 10;j++){
		if(buffer[j] != 109){
		   printf(1,"consumer has : %d\n", buffer[j]);
		   buffer[j] = 109;
		   //printf(1,"consumer after: %d\n", buffer[j]);
		}	
	}	

	mtx_unlock(mutex);
	printf(1,"consumer is done \n");
	sleep(10);

	

	exit();

}

int main(int argc, char *argv[])
{
	//int j;
	mutex =mtx_create(0);
	char *arg ="mmmmmmmmmmmmmmmmmmmm";
	//char arg[20] ="mmmmmmmmmmmmmmmmmmmm"
	//int* arg = (int*)malloc(10*sizeof(int *));
	//memset(arg, 20, 10*sizeof(int*));


	printf(1,"argggg inittttttttt %d\n", arg[0]);
	printf(1,"argggg inittttttttt %d\n", arg[1]);
	stack = (uint*)malloc(1024*sizeof(uint));

	uint* r_stack = (uint*)0;
	// printf(1,"thread_create %d\n", stack);
	// printf(1,"thread_create2 %d\n", &r_stack);
	//for( j= 0; j< 3; j++){
		//int v = thread_create(tmain, (void*)stack, (void*)arg);
		// printf(1,"thread_create3 %d\n", v);
		// printf(1, "argumentttttt: %d\n", (char*)arg);


	int v =thread_create(*producer, (void*)stack, (void*)arg);	

	thread_join((void **)&r_stack);

	//}
	printf(1,"main pid = %d, producer thread pid = %d\n", getpid(), v);
  	sleep(50);
	printf(1,"sssssssssssssss\n" );

	int x = thread_create(consumer, (void*)stack, (void*)arg);
	printf(1,"main pid  = %d, consumer pid pid = %d\n", getpid(), x);	

	thread_join((void **)&r_stack);



	printf(1,"end of main \n" );

	//free(stack);
	free(r_stack);
	//printf(1,"thread_join return value%d\n", r);
	exit();
	return 0;
}


