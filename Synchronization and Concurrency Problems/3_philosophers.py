from threading import Semaphore, Thread
from time import sleep
from timeit import Timer
import random

rand = random.Random()
rand.seed(100)


#num of philosopher
num_p = 20
# num of meal/philosopher
r =100


#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#Tanenbaum left philosopher function
def t_left(i):
	return (i+num_p-1)%num_p

#footman and lefthand left function
def left(i):
	return i

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


#############footman################
footman = Semaphore(num_p-1)
footman_forks =[Semaphore(1) for i in range(num_p)]

def footman_totime():
    ts = [Thread(target=footman_come, args=[i,footman_forks]) for i in range(num_p)]
    #print('****')
    for t in ts: t.start()
    for t in ts: t.join()

def footman_get_fork(i,footman_forks):
	footman.acquire()
	#print("philosopher " + str(i) + " comes")
	footman_forks[right(i)].acquire()
	footman_forks[left(i)].acquire()
	eating()

def footman_put_fork(i,footman_forks):
	footman_forks[right(i)].release()
	footman_forks[left(i)].release()
	footman.release()
	#print("philosopher " + str(i) + " has done his meal")
	thinking()

def footman_come(i,footman_forks):
	for j in range (0,r):
		footman_get_fork(i,footman_forks)
		footman_put_fork(i,footman_forks)

		#print("fottman -- p "+str(i)+ " round: " + str(j))

#############footman################


#############left_hand solution################

left_hand_forks =[Semaphore(1) for i in range(num_p)]
temp = random.randint(0, num_p-1)

def left_hand_totime():
    ts = [Thread(target=left_hand, args=[i,left_hand_forks]) for i in range(num_p)]
    for t in ts: t.start()
    for t in ts: t.join()

def left_hand(i,left_hand_forks):

	#print("*******temp: " + str(temp) + " ********")
	for j in range (0,r):
		if(i == 1):
			#print("1111 get fork left : " + str(i))
			left_hand_forks[left(i)].acquire()
			#print("1111 get fork left : " + str(right(i)))
			left_hand_forks[right(i)].acquire()

		else:
			#print("right 3333: " + str(right(i)) )
			left_hand_forks[right(i)].acquire()
			#print("left 555555; " + str(i))
			left_hand_forks[left(i)].acquire()

		eating()
		left_hand_forks[right(i)].release()
		left_hand_forks[left(i)].release()
		thinking()
		#print("left_hand -- p "+str(i)+ " round: " + str(j))

#############left_hand solution################



#############Tanenbaum's solution################
Tanenbaum_forks =[Semaphore(0) for i in range(num_p)]

t_mutex =Semaphore(1)

state=['thinking']*num_p
#store how many meal philosopher has eaten
count=[0]*num_p


def Tanenbaum_totime():
    ts = [Thread(target=Tanenbaum, args=[i,Tanenbaum_forks,state]) for i in range(num_p)]
    for t in ts: t.start()
    for t in ts: t.join()


def test(i):
	if state[i] == 'hungry' and state[t_left(i)] != 'eating' and state[right(i)] != 'eating':
		#I only consider one situation, num of meals for current philosopher has eaten is 
		# not larger than num of meals for his left or right philosopher
		if count[t_left(i)] - count[i] >= 0 and count[right(i)] - count[i] >= 0:
			state[i] = 'eating'
			print(i)
			count[i]+=1
			Tanenbaum_forks[i].release()

	
def t_get_fork(i):
	t_mutex.acquire()
	state[i]='hungry'
	test(i)
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
	
	#--------footman------
	timer1 = Timer(footman_totime)
	print("1. Footman solution---Time: {:0.3f}s".format(timer1.timeit(10)/10))
	#--------footman------
	#print("aaaaaaaaaa")
	#--------left_hand solution------
	timer2 = Timer(left_hand_totime)
	print("2. left_hand solution ---Time: {:0.3f}s".format(timer2.timeit(10)/10))
	#--------left_hand solution------

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
	

