from threading import Semaphore, Thread
from time import sleep
from timeit import Timer
import random

rand = random.Random()
rand.seed(100)


#num of philosopher
num_p = 5
# num of meal/philosopher
r =100

#############Tanenbaum's solution################

#Tanenbaum left philosopher function
def t_left(i):
	return (i+num_p-1)%num_p

def right(i):
	return (i+1)%num_p

def thinking():
	sleep(rand.random()/10)
	#sleep(0.00001)
	#sleep(rand.random()/10)

def eating():
	#print("philosopher " + str(i) + " is eating")
	sleep(rand.random()/10)
	#sleep(rand.random())
	#sleep(rand.random()/10)

Tanenbaum_forks =[Semaphore(0) for i in range(num_p)]
check =[0 for i in range(num_p)]
t_mutex =Semaphore(1)

state=['thinking']*num_p
#Tanenbaum_forks =[Semaphore(1) for i in range(num_p)]
#store how many meal philosopher has eaten
count=[0]*num_p
semaphore =Semaphore(1)
global max_one
max_one = 0
global min_one
min_one = 0

def Tanenbaum_totime():
    ts = [Thread(target=Tanenbaum, args=[i,Tanenbaum_forks,state]) for i in range(num_p)]
    for t in ts: t.start()
    for t in ts: t.join()


	

def test(i):
	
	if state[i] == 'hungry' and state[t_left(i)] != 'eating' and state[right(i)] != 'eating':
		if count[i] <=3:
			state[i] = 'eating'
			#print(i)
			count[i]+=1
			Tanenbaum_forks[i].release()
		else:
			temp=0
			for p in range(0,num_p):
				if count[p]==4:
					temp=temp+1

			if temp == num_p:
				for q in range(0,num_p):
					count[q]=0
				test(i)
				

def t_get_fork(i):
	t_mutex.acquire()
	state[i]='hungry'
	#print(str(i)+ 'is hungry')
	test(i)
	#print('get test end')
	t_mutex.release()
	Tanenbaum_forks[i].acquire()

	
def t_put_fork(i):
	t_mutex.acquire()
	state[i] ='thinking'
	test(right(i))
	test(t_left(i))
	t_mutex.release()

def Tanenbaum(i,Tanenbaum_forks,state):
	for j in range (0,r):
		t_get_fork(i)
		eating()
		t_put_fork(i)
		thinking()

		


#############Tanenbaum's solution################

def main():
	
	
	#--------Tanenbaum's solution------
	timer3 = Timer(Tanenbaum_totime)
	print("3. Tanenbaum solution ---Time: {:0.3f}s".format(timer3.timeit(10)/10))
	#--------Tanenbaum's solution------

	#for c in range(0,num_p):
		#thread = Thread(target=footman_come,args=(c,footman_forks))
		#thread.start()
		#sleep(rand.random())

if __name__ == "__main__":
	main()