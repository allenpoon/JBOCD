Network::Network(){}
short Network::toShort(unsigned char* in){
	short out = 0;
	return (out | in[0]) << 8 | in[1];
}
int Network::toInt(unsigned char* in){
	int out = 0;
	return ((((((out | in[0]) << 8 ) | in[1]) << 8 ) | in[2]) << 8 ) | in[3];
}
long long Network::toLongLong(unsigned char*){
	long long out = 0;
	return ((((((((((((((out | in[0]) << 8 ) | in[1]) << 8 ) | in[2]) << 8 ) | in[3]) << 8) | in[4]) << 8 ) | in[5]) << 8 ) | in[6]) << 8 ) | in[7];
}
char* Network::toChars(unsigned char* in){
	int len = Network::toInt(in);
	char * out = (char*) malloc(len+1);
	in = in+4;
	for(int i=0;i<len;i++){
		out[i]=in[i];
	}
	out[len]=0;
	return out;
}
void Network::toBytes(short value, unsigned char* ptr){
	ptr[1] = (unsigned char) ( (value       ) & 0xFF);
	ptr[0] = (unsigned char) ( (value >>  8 ) & 0xFF);
}
void Network::toBytes(int value, unsigned char* ptr){
	ptr[3] = (unsigned char) ( (value       ) & 0xFF);
	ptr[2] = (unsigned char) ( (value >>  8 ) & 0xFF);
	ptr[1] = (unsigned char) ( (value >> 16 ) & 0xFF);
	ptr[0] = (unsigned char) ( (value >> 24 ) & 0xFF);
}
void Network::toBytes(long long value, unsigned char* ptr){
	ptr[7] = (unsigned char) ( (value       ) & 0xFF);
	ptr[6] = (unsigned char) ( (value >>  8 ) & 0xFF);
	ptr[5] = (unsigned char) ( (value >> 16 ) & 0xFF);
	ptr[4] = (unsigned char) ( (value >> 24 ) & 0xFF);
	ptr[3] = (unsigned char) ( (value >> 32 ) & 0xFF);
	ptr[2] = (unsigned char) ( (value >> 40 ) & 0xFF);
	ptr[1] = (unsigned char) ( (value >> 48 ) & 0xFF);
	ptr[0] = (unsigned char) ( (value >> 56 ) & 0xFF);
}
void Network::toBytes(char* value, unsigned char* ptr){
	int len = 0;
	while(*(value+len)!=0){
		len++;
		*(ptr+len+4) = *(value+len);
	}
	Network::toBytes(len, ptr);
}
int Network::getLength(short value, int len){
	return len + 2;
}
int Network::getLength(int value, int len){
	return len + 4;
}
int Network::getLength(long long value, int len){
	return len + 8;
}
int Network::getLength(char* value, int len){
	int tmp = 0;
	while(*(value+tmp)!=0){
		tmp++;
	}
	return len+4+tmp;
}