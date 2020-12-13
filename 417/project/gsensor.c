#include "ADXL345.h"
#include <fcntl.h>
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <unistd.h>

#define HW_REGS_BASE (0xff200000 )
#define HW_REGS_SPAN (0x00200000 )
#define HW_REGS_MASK (HW_REGS_SPAN - 1)
#define LED_PIO_BASE 0x0
#define SSEG_PIO_BASE 0x20
#define SW_PIO_BASE 0x40

volatile sig_atomic_t stop;

void catchSIGINT(int signum) {
	stop = 1;
}

int sseg_v[16] = {0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02,
0x78, 0x00, 0x10, 0x08, 0x03, 0x42, 0x21, 0x06, 0x0E};

unsigned long long getss(int num) {
	// Convert into hexadecimal digits.
	int nums[6] = {
		(int)(num/pow(16,5))%16,
		(int)(num/pow(16,4))%16,
		(int)(num/pow(16,3))%16,
		(int)(num/pow(16,2))%16,
		(int)(num/16)%16,
		num%16
	};
	// Get the 7-segment code for each digit.
	unsigned long long sc[6] = {sseg_v[nums[5]], sseg_v[nums[4]], sseg_v[nums[3]],
sseg_v[nums[2]], sseg_v[nums[1]], sseg_v[nums[0]]};
	unsigned long long d = sc[0]|(sc[1]<<8)|(sc[2]<<16)|(sc[3]<<24)|(sc[4]<<32)|(sc[5]<<40);
	return ~d;
}

int main(void) {
	volatile unsigned int *h2p_lw_led_addr=NULL;
	volatile unsigned int *h2p_lw_sw_addr=NULL;
	volatile unsigned int *h2p_lw_7seg_addr=NULL;
	void *virtual_base;
	int fd;

	signal(SIGINT, catchSIGINT);

	if ((fd=open("/dev/mem",(O_RDWR|O_SYNC))) == -1) {
		printf("ERROR: could not open \"dev/mem\"...\n");
		return(1);
	}
	virtual_base = mmap(NULL,HW_REGS_SPAN,(PROT_READ|PROT_WRITE),MAP_SHARED,fd,HW_REGS_BASE);
	if (virtual_base==MAP_FAILED) {
		printf("ERROR: mmap() failed...\n");
		close(fd);
		return (1);
	}
	h2p_lw_led_addr=(unsigned int*)(virtual_base+((LED_PIO_BASE)&(HW_REGS_MASK)));
	h2p_lw_sw_addr=(unsigned int*)(virtual_base+((SW_PIO_BASE)&(HW_REGS_MASK)));
	h2p_lw_7seg_addr=(unsigned int*)(virtual_base+((SSEG_PIO_BASE)&(HW_REGS_MASK)));

	uint8_t devid;
	int16_t mg_per_lsb = 4;
	int16_t XYZ[3];

	int x, y, z;
	Map_Physical_Addrs();
	Pinmux_Config();
	I2C0_Init();
	ADXL345_REG_READ(0x00, &devid);

	if (devid == 0xE5) {
		printf("Device ID Verified\n");
		ADXL345_Init();
		printf("ADXL345 Initialized\n");

		int led = 0, tilt_total = 0;
		int cycles_passed = 0, s_passed = 0;
		
		while (1) {
			if (ADXL345_IsDataReady()) {
				cycles_passed += 1;
				if (cycles_passed >= 100) {
					if ((*h2p_lw_sw_addr&(1<<0))>>0==0) {
						s_passed += 1;
					}
					if ((*h2p_lw_sw_addr&(1<<1))>>1==1) {
						s_passed = 0;
					}
					cycles_passed -= 100;
				}

				if (cycles_passed % 6 != 0) {
					continue;
				}

				ADXL345_XYZ_Read(XYZ);
				x = (XYZ[0] + 250)/25;
				y = (XYZ[1] + 250)/50;
				z = (XYZ[2] + 250)/50;
				x = (x > 20) ? 20 : (x < 0 ? 0 : x);
				y = (y > 10) ? 10 : (y < 0 ? 0 : y);
				z = (z > 10) ? 10 : (z < 0 ? 0 : z);
				led = 8-((XYZ[0]*mg_per_lsb+1000)/250);

				if ((*h2p_lw_sw_addr&(1<<1))>>1==1) {
					tilt_total = 0;
				}
				if ((*h2p_lw_sw_addr&(1<<0))>>0==0) {
					tilt_total += (int)(pow(3,abs(4-led))/3);
					*h2p_lw_7seg_addr = getss(tilt_total/10);
				} else {
					if (s_passed != 0) {
						*h2p_lw_7seg_addr = getss(tilt_total/s_passed);
					} else {
						*h2p_lw_7seg_addr = getss(0);
					}
				}

				*h2p_lw_led_addr = pow(2, led);
				fflush(stdout);
			}
		}
	} else {
		printf("Incorrect device ID\n");
	}

	if (munmap(virtual_base, HW_REGS_SPAN) != 0) {
		printf("ERROR: munmap() failed...\n");
		close(fd);
		return (1);
	}
	close(fd);
	Close_Device();
	return 0;
}