from threading import Semaphore, Thread
from time import sleep
import random
rand = random.Random()
rand.seed(100)

class SharedStash:
	def __init__(self):
		self.stash_value = 20
		self.disc_on_field_value =0
		self.mutex=Semaphore(1)

semaphore= Semaphore(0)
dof_mutex =Semaphore(0)


def frolfer(id, N, s):
	s.mutex.acquire()
	if s.stash_value < N:
		semaphore.release()
		dof_mutex.acquire()
		s.mutex.acquire()

	s.stash_value -=N
	print("Frolfer "+ str(id)+ " got 5 discs, stash : " + str(s.stash_value ))
	s.mutex.release()

def play(id,N,s):
	while True:
		print("Frolfer "+ str(id)+" calling for bucket")
		frolfer(id,N,s)
		for i in range(0,N):	
			throw_disc(i,id,s)
			


def throw_disc(i,id,s):
	dof_mutex.acquire()
	sleep(rand.random())
	s.disc_on_field_value+=1
	print("Frolfer "+ str(id)+ " threw disc " + str(i))
	dof_mutex.release()


def cart(s,N):
	while True:
		s.mutex.acquire()
		if s.stash_value > N-1:
			print("555555")
			dof_mutex.release()
			s.mutex.release()
			# priority here
			semaphore.acquire()

		
		if s.stash_value < N:
			print("############")
			print("stash = " + str(s.stash_value) +", dof= " + str(s.disc_on_field_value ) +" ; Cart entering field")
			s.stash_value  += s.disc_on_field_value 
			print("Cart done, after gathered "+ str(s.disc_on_field_value) + ", dics Stash = " + str(s.stash_value))
			s.disc_on_field_value= 0
			print("############")
		dof_mutex.release()
		s.mutex.release()
	



def main():
	
	num = int(input('Enter num of player: '))
	print('num of player: ', num)
	s.stash_value = int(input('Enter initial Stash: '))
	print('initial Stash: ', s.stash_value)
	N = int(input('Enter initial N : '))
	print('initial N is: ', N)
	print("initial discs_on_field is 0")

	thread_cart= Thread(target=cart, args=(s,N))
	thread_cart.start()

	for c in range(0,num):
		thread = Thread(target=play,args=(c,N,s))
		thread.start()
		sleep(rand.random())
	


if __name__ == "__main__":
	s= SharedStash()
	main()