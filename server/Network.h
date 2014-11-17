#ifndef NETWORK_H
#define NETWORK_H

class Network{
	public:
		Network();

		// in 32 bit system, short=16bit, int=32bit, long=32bit, long long=64bit
		// in 64 bit system, short=16bit, int=32bit, long=64bit, long long=64bit
		// for compatitability, we use "short", "int", and "long long"
		static short toShort(char*);
		static int toInt(char*);
		static long long toLong(char*);
		static char* toChars(char*);
		static void toBytes(short value, unsigned char* ptr);
		static void toBytes(int value, unsigned char* ptr);
		static void toBytes(long long value, unsigned char* ptr);
		static void toBytes(char* value, unsigned char* ptr);
		static int getLength(short value, int len);
		static int getLength(int value, int len);
		static int getLength(long long value, int len);
		static int getLength(char* value, int len);
};

#include "Network.cpp"

#endif