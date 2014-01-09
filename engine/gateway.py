#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import time
import logging
import traceback
import argparse
from functools import wraps

import sphero

from py4j.java_gateway import JavaGateway
from py4j.java_gateway import GatewayClient

##
## @note ロギングの設定
##
#logging.basicConfig(level=logging.DEBUG)

##
## @note オプションパーサの設定
##
parser = argparse.ArgumentParser(description='the gateway module of python to control sphero.')
args = parser.parse_args()

def exception_handling(f):
	@wraps(f)
	def wrapper (*args, **kwargs):
		try:
			return f(*args, **kwargs)
		except:
			logging.error (traceback.format_exc())
			return None
	return wrapper

class Sphero (object):
	def __init__(self): 
		self.sphero_ = sphero.Sphero()
		#print self.sphero_

	@exception_handling
	def set_sphero (self, path=''): return self.sphero_.set_sphero(path)

	@exception_handling
	def paired_spheros (self): return self.sphero_.paired_spheros()

	@exception_handling
	def connect (self): self.sphero_.connect()

	@exception_handling
	def write (self, bytes): self.sphero_.write(str(bytes))

	@exception_handling
	def ping (self): self.sphero_.ping()

	@exception_handling
	def set_rgb (self, r, g, b, persistant): self.sphero_.set_rgb(r, g, b, persistant)

	@exception_handling
	def get_rgb (self): 
		'@note currently replying ?,?,?. so always returing zero.'
		#rgb = self.sphero_.get_rgb()
		return 0

	@exception_handling
	def get_device_name (self): return self.sphero_.get_device_name()

	@exception_handling
	def set_device_name (self, newname): self.sphero_.set_device_name(newname)

	@exception_handling
	def get_bluetooth_info (self): 
		bluetooth_info = self.sphero_.get_bluetooth_info()
		return ','.join((str(bluetooth_info.name), str(bluetooth_info.bta)))

	@exception_handling 
	def sleep (self, wakeup, macro, orbbasic): self.sphero_.sleep(wakeup, macro, orbbasic)

	@exception_handling
	def set_heading (self, value): self.sphero_.set_heading(value)

	@exception_handling
	def set_stabilization (self, state): self.sphero_.set_stabilization(state)

	@exception_handling
	def set_rotation_rate (self, val): self.sphero_.set_rotation_rate(val)

	@exception_handling
	def set_back_led_output (self, value): self.sphero_.set_back_led_output(value)

	@exception_handling
	def roll (self, speed, heading, state): self.sphero_.roll(speed, heading, state)

	@exception_handling
	def stop (self): self.sphero_.stop()

	class Java:
		implements = ['SpheroControl$Sphero']

class Gateway (object):
	def __init__(self):
		self.gateway_ = None
		self.active = False

	def setup (self):
		try:
			if self.active: return
			self.gateway_ = JavaGateway(start_callback_server=True)
			self.active = True
			return True
		except:
			logging.error (traceback.format_exc())
			return False

	def shutdown (self):
		try:
			if not self.active: return
			self.gateway_.shutdown()
		except:
			logging.error (traceback.format_exc())

	def register (self, control):
		try:
			self.gateway_.entry_point.register(control)
			return True
		except:
			logging.error (traceback.format_exc())
			return False


## test of sphero control
def test_control ():
	try:
		import time
		import random

		s = Sphero()
		s.connect()

		print 'gonna set sphero ...'
		s.set_sphero()
		print 'paired_spheros: ', s.paired_spheros()
		print 'gonna ping ...'
		s.ping()
		print 'rgb info: ', str(s.get_rgb())
		print 'setting spheros name as hoge ...'
		s.set_device_name('hoge')
		print 'device name: ', s.get_device_name()
		print 'bluetooth info: ', s.get_bluetooth_info()
		#print 'gonna sleep ...'
		#s.sleep(0,0,0)
		print 'setting head as 30'
		s.set_heading(30)
		print 'set_stabilization as 1'
		s.set_stabilization(1)
		print 'set rotation rate as 0x20'
		s.set_rotation_rate(0x20)
		print 'set back led output as 0x20'
		s.set_back_led_output(0x20)

		print 'gonna roll and color change demo 10 times '
		for x in range(10):
			try:
				s.roll(0x80, 270, 1)
				s.set_rgb(random.randint(0,255),random.randint(0, 255), random.randint(0,255), False)
				time.sleep(3)
				print '.',
			except KeyboardInterrupt, e:
				logging.error (traceback.format_exc())
				break

		print 'gonna sleep for 3 seconds'
		s.sleep(3, 0, 0)
		print 'sleep thread 10 seconds .'
		for i in range(10):
			print '.',
			time.sleep(1)

		## will output error, b/c previously sleep the sphero.
		print 'gonna stop and exit'
		s.stop()
	except:
		logging.error (traceback.format_exc())


if __name__ == '__main__': #test_control()
	try:
		import time

		gateway = Gateway()
		if not gateway.setup():
			logging.debug("fail to setup connections. gonna exit.")
			sys.exit()

		sphero_ = Sphero()
		sphero_.connect()
		gateway.register (sphero_)

		while True:
			time.sleep(1.0)

		gateway.shutdown()
	except:
		logging.error(traceback.format_exc())
