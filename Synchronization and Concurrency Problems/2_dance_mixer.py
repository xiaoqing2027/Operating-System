from threading import Semaphore, Thread
from time import sleep
from timeit import Timer
from collections import deque
import itertools
import random

rand = random.Random()
rand.seed(100)
num_leader = 3
num_follower = 8


l = deque([],maxlen=num_leader)
f = deque([],maxlen=num_follower)

l_s = deque([],maxlen=num_leader)
f_s = deque([],maxlen=num_follower)

lstage = Semaphore(1)
fstage = Semaphore(1)

lArrived = Semaphore(0)
fArrived = Semaphore(0)

lpassed = Semaphore(0)
fpassed = Semaphore(0)

lback = Semaphore(0)
fback = Semaphore(0)

room = Semaphore(1)
turnstile =Semaphore(1)
dance_finish =Semaphore(0)


class Lightswitch:
	def __init__(self):
		self.counter = 0
		self.mutex = Semaphore(1)
		self.current_leader = 0
		self.current_follower =0
	def lock(self, semaphore):
		self.mutex.acquire()
		self.counter+=1
		if self.counter == 1:
			semaphore.acquire()
		self.mutex.release()

	def unlock(self, semaphore):
		self.mutex.acquire()
		self.counter-=1
		if self.counter == 0:
			semaphore.release()
		self.mutex.release()
		



def main():
	
	band = Thread(target=music_start)
	band.start()
	
	for lid in range(0,num_leader):
		l.append(lid)
		#print(l)
		leader = Thread(target=leaders_goto_stage,args=(l,v))
		leader.start()


	for fid in range(0,num_follower):
		f.append(fid)
		#print(f)
		follower = Thread(target=followers_goto_stage,args=(f,v))
		follower.start()


def music_start():
	while True:
		for music in itertools.cycle(['waltz', 'tango', 'foxtrot']):
			print("**Band leader started playing "+ music+" **")
			sleep(5)
			## acquire stage
			turnstile.acquire()
			room.acquire()
			print("------------")
			print("**Band leader end "+ music+" **")
			turnstile.release()
			room.release()


def leaders_goto_stage(l,v):
	while True:
		lstage.acquire()
		turnstile.acquire()
		turnstile.release()	
		if l:
			lArrived.release()
			fArrived.acquire()
			v.lock(room)
			v.current_leader = l.popleft()
			print('leader ' + str(v.current_leader) +' entering floor')
			lpassed.release()
			pairup_and_dance(v)
			lstage.release()
			
			sleep(rand.random())
			lback.acquire()
			leader_back()
			#follower_back()
			v.unlock(room)
		else:
			v.unlock(room)
			lstage.release()
		

def followers_goto_stage(f,v):
	while True:
		turnstile.acquire()
		turnstile.release()
		fstage.acquire()
		if f:
			fArrived.release()
			lArrived.acquire()
			
			v.lock(room)
			v.current_follower = f.popleft()
			print('follower ' + str(v.current_follower) +' entering floor')	
			fpassed.release()
			dance_finish.acquire()
			fstage.release()

			sleep(rand.random())
			fback.acquire()
			follower_back()
			#leader_back()
			v.unlock(room)

		else:
			v.unlock(room)
			fstage.release()

def pairup_and_dance(v):
	fpassed.acquire()
	lpassed.acquire()
	print('leader ' + str(v.current_leader) +" and follower " + str(v.current_follower)+ ' are dancing')
	l_s.append(v.current_leader)
	f_s.append(v.current_follower)
	dance_finish.release()
	lback.release()
	fback.release()

	
def leader_back():
	v.mutex.acquire()
	if l_s:
		temp1 = l_s.popleft()
		print('leader ' + str(temp1) +' backing in line')
		l.append(temp1)
	v.mutex.release()



def follower_back():
	v.mutex.acquire()
	if f_s:
		temp2 = f_s.popleft()
		print('follower ' + str(temp2) +' backing in line')
		f.append(temp2)
	v.mutex.release()
			



if __name__ == "__main__":
	v =Lightswitch()
	main()
