#include <Keyboard.h>
#include <hidboot.h>
unsigned long a = 0;
unsigned long r = 0;
unsigned long t = 0;
unsigned long s = 0;
unsigned long e = 0;
unsigned long y = 0;
unsigned long i = 0;
unsigned long o = 0;
unsigned long now = 0;
byte state;
bool nav;
bool mouse;
bool lck;
byte prev = 0;

void releaseAll()
{
	Keyboard.releaseAll();
	if (lck)
		Keyboard.press(((char)129));
}

void press(byte key)
{
	if ((key > 127) && (key < 132)) {
		if (key == prev)
			releaseAll();
		else
			Keyboard.press(((char)key));
		prev = key;
		return;
	}
	Keyboard.write(((char)key));
	releaseAll();
	prev = key;
}

class KbdRptParser : public KeyboardReportParser
{
protected:

	void OnKeyDown(uint8_t ignore, uint8_t oem)
	{
		now = millis();
		switch (oem)
		{
			case 21:
				a = now;
				break;
			case 8:
				r = now;
				break;
			case 26:
				t = now;
				break;
			case 20:
				s = now;
				break;
			case 9:
				e = now;
				break;
			case 7:
				y = now;
				break;
			case 22:
				i = now;
				break;
			case 4:
				o = now;
				break;
		}
	}

	void OnKeyUp(uint8_t ignore, uint8_t oem)
	{
		now = millis();
		state = 0;
		if ((now - a) < 200) {
			state = state | (1 << 4);
			a = 0;
		}
		if ((now - r) < 200) {
			state = state | (1 << 5);
			r = 0;
		}
		if ((now - t) < 200) {
			state = state | (1 << 6);
			t = 0;
		}
		if ((now - s) < 200) {
			state = state | (1 << 7);
			s = 0;
		}
		if ((now - e) < 200) {
			state = state | (1 << 0);
			e = 0;
		}
		if ((now - y) < 200) {
			state = state | (1 << 1);
			y = 0;
		}
		if ((now - i) < 200) {
			state = state | (1 << 2);
			i = 0;
		}
		if ((now - o) < 200) {
			state = state | (1 << 3);
			o = 0;
		}
		switch (oem)
		{
			case 21:
				a = 0;
				break;
			case 8:
				r = 0;
				break;
			case 26:
				t = 0;
				break;
			case 20:
				s = 0;
				break;
			case 9:
				e = 0;
				break;
			case 7:
				y = 0;
				break;
			case 22:
				i = 0;
				break;
			case 4:
				o = 0;
				break;
		}
		//z
		if (state == 240) {
			press(122);
			return;
		}
		//shift
		if (state == 225) {
			press(129);
			return;
		}
		//tab
		if (state == 120) {
			press(179);
			return;
		}
		//caps lock
		if (state == 30) {
			press(193);
			return;
		}
		//space
		if (state == 15) {
			press(32);
			return;
		}
		//x
		if (state == 224) {
			press(120);
			return;
		}
		//q
		if (state == 208) {
			press(113);
			return;
		}
		//d
		if (state == 112) {
			press(100);
			return;
		}
		//esc
		if (state == 56) {
			press(177);
			return;
		}
		//nav
		if (state == 37) {
			nav = !nav;
			return;
		}
		//apos
		if (state == 22) {
			press(39);
			return;
		}
		//m
		if (state == 14) {
			press(109);
			return;
		}
		//p
		if (state == 13) {
			press(112);
			return;
		}
		//l
		if (state == 7) {
			press(108);
			return;
		}
		//j
		if (state == 192) {
			press(106);
			return;
		}
		//v
		if (state == 160) {
			press(118);
			return;
		}
		//w
		if (state == 144) {
			press(119);
			return;
		}
		//alt
		if (state == 132) {
			press(130);
			return;
		}
		//gui
		if (state == 130) {
			press(131);
			return;
		}
		//control
		if (state == 129) {
			press(128);
			return;
		}
		//8
		if ((state == 96) && (s != 0) && ((now - s) > 200)) {
			press(56);
			return;
		}
		//g
		if (state == 96) {
			press(103);
			return;
		}
		//bang
		if (state == 68) {
			press(33);
			return;
		}
		//7
		if ((state == 48) && (s != 0) && ((now - s) > 200)) {
			press(55);
			return;
		}
		//f
		if (state == 48) {
			press(102);
			return;
		}
		//delete
		if (state == 36) {
			press(212);
			return;
		}
		//shift lock
		if (state == 34) {
			lck = !lck;
			if (lck)
				press(129);
			else
				Keyboard.release(129);
			return;
		}
		//backspace
		if (state == 33) {
			press(178);
			return;
		}
		//forward slash
		if (state == 24) {
			press(47);
			return;
		}
		//comma
		if (state == 20) {
			press(44);
			return;
		}
		//period
		if (state == 18) {
			press(46);
			return;
		}
		//enter
		if (state == 17) {
			press(176);
			return;
		}
		//n
		if (state == 12) {
			press(110);
			return;
		}
		//k
		if (state == 10) {
			press(107);
			return;
		}
		//b
		if (state == 9) {
			press(98);
			return;
		}
		//0
		if ((state == 6) && (s != 0) && ((now - s) > 200)) {
			press(48);
			return;
		}
		//u
		if (state == 6) {
			press(117);
			return;
		}
		//h
		if (state == 5) {
			press(104);
			return;
		}
		//9
		if ((state == 3) && (s != 0) && ((now - s) > 200)) {
			press(57);
			return;
		}
		//c
		if (state == 3) {
			press(99);
			return;
		}
		//page up
		if ((state == 128) && nav) {
			press(211);
			return;
		}
		//backtick
		if ((state == 128) && (e != 0) && ((now - e) > 200)) {
			press(96);
			return;
		}
		//open curly
		if ((state == 128) && (a != 0) && ((now - a) > 200)) {
			press(123);
			return;
		}
		//s
		if (state == 128) {
			press(115);
			return;
		}
		//home
		if ((state == 64) && nav) {
			press(210);
			return;
		}
		//3
		if ((state == 64) && (s != 0) && ((now - s) > 200)) {
			press(51);
			return;
		}
		//semicolon
		if ((state == 64) && (e != 0) && ((now - e) > 200)) {
			press(59);
			return;
		}
		//open para
		if ((state == 64) && (a != 0) && ((now - a) > 200)) {
			press(40);
			return;
		}
		//t
		if (state == 64) {
			press(116);
			return;
		}
		//up
		if ((state == 32) && nav) {
			press(218);
			return;
		}
		//2
		if ((state == 32) && (s != 0) && ((now - s) > 200)) {
			press(50);
			return;
		}
		//backslash
		if ((state == 32) && (e != 0) && ((now - e) > 200)) {
			press(92);
			return;
		}
		//close para
		if ((state == 32) && (a != 0) && ((now - a) > 200)) {
			press(41);
			return;
		}
		//r
		if (state == 32) {
			press(114);
			return;
		}
		//end
		if ((state == 16) && nav) {
			press(213);
			return;
		}
		//1
		if ((state == 16) && (s != 0) && ((now - s) > 200)) {
			press(49);
			return;
		}
		//bang
		if ((state == 16) && (e != 0) && ((now - e) > 200)) {
			press(33);
			return;
		}
		//a
		if (state == 16) {
			press(97);
			return;
		}
		//page down
		if ((state == 8) && nav) {
			press(214);
			return;
		}
		//equals
		if ((state == 8) && (e != 0) && ((now - e) > 200)) {
			press(61);
			return;
		}
		//close curly
		if ((state == 8) && (a != 0) && ((now - a) > 200)) {
			press(125);
			return;
		}
		//o
		if (state == 8) {
			press(111);
			return;
		}
		//left
		if ((state == 4) && nav) {
			press(216);
			return;
		}
		//6
		if ((state == 4) && (s != 0) && ((now - s) > 200)) {
			press(54);
			return;
		}
		//minus
		if ((state == 4) && (e != 0) && ((now - e) > 200)) {
			press(45);
			return;
		}
		//open square
		if ((state == 4) && (a != 0) && ((now - a) > 200)) {
			press(91);
			return;
		}
		//i
		if (state == 4) {
			press(105);
			return;
		}
		//down
		if ((state == 2) && nav) {
			press(217);
			return;
		}
		//5
		if ((state == 2) && (s != 0) && ((now - s) > 200)) {
			press(53);
			return;
		}
		//question
		if ((state == 2) && (e != 0) && ((now - e) > 200)) {
			press(63);
			return;
		}
		//close square
		if ((state == 2) && (a != 0) && ((now - a) > 200)) {
			press(93);
			return;
		}
		//y
		if (state == 2) {
			press(121);
			return;
		}
		//right
		if ((state == 1) && nav) {
			press(215);
			return;
		}
		//4
		if ((state == 1) && (s != 0) && ((now - s) > 200)) {
			press(52);
			return;
		}
		//e
		if (state == 1) {
			press(101);
			return;
		}
	}
};
USB Usb;
HIDBoot<USB_HID_PROTOCOL_KEYBOARD> HidKeyboard(&Usb);
KbdRptParser Prs;

void setup()
{
	lck = false;
	nav = false;
	mouse = false;
	Usb.Init();
	HidKeyboard.SetReportParser(0, &Prs);
	Keyboard.begin();
}

void loop()
{
	Usb.Task();
}