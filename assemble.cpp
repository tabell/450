// basic assembler for toy project, ceng 450 uvic spring 2015
// usage: assembler <instructions.txt>
// this will overwrite imem.vhd but it will make a backup if and only if
// the target backup file does not exist

#include <stdlib.h>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <string.h>
#include <sstream>  //for std::istringstream
#include <iterator> //for std::istream_iterator
#include <vector>   //for std::vector
#include <queue>
#include <algorithm>
#include <bitset>

using std::cout;
using std::endl;
using std::ifstream;
using std::string;
using std::istringstream;
using std::istream_iterator;
using std::vector;

#define OPCODE_NOP (0<<4);
#define OPCODE_LOAD (1<<4);
#define OPCODE_STORE (2<<4);
#define OPCODE_LOADIMM (3<<4);
#define OPCODE_ADD (4<<4);
#define OPCODE_SUB (5<<4);
#define OPCODE_SHL (6<<4);
#define OPCODE_SHR (7<<4);
#define OPCODE_NAND (8<<4);
#define OPCODE_BR (9<<4);
#define OPCODE_BRZ (9<<4);
#define OPCODE_BRN (9<<4);
#define OPCODE_BRSUB (9<<4);
#define OPCODE_PUSH (10<<4);
#define OPCODE_POP (10<<4);
#define OPCODE_IN (11<<4);
#define OPCODE_OUT (12<<4);
#define OPCODE_MOV (13<<4);
#define OPCODE_RET (14<<4);
#define OPCODE_RTI (14<<4);

#define REG_R0 0
#define REG_R1 1
#define REG_R2 2
#define REG_R3 3

bool is_file_exist(const char *fileName)
{
	std::ifstream infile(fileName);
	return infile.good();
}


int main(int argc, char** argv)
{
	unsigned char result[128];
	for (int i=0;i<128;i++) result[i]=0;
		vector<string> pre, post;
	std::queue<string> data;
	if (argc <= 1)
	{
		cout << "Error: You must specify the source file" << endl;
		return 0;
	}
	ifstream file(argv[1]);
	ifstream file2("imem.vhd");
	string line;
	string contents;

	int found_pre = 0;
	int found_post = 0;
	size_t found;
	while(std::getline(file2, line))
	{
		if (found_pre == 0)
			pre.push_back(line);
		found = line.find("constant rom_content : ROM_TYPE := (");
			if (found != string::npos) found_pre = 1;
			if (line.compare("begin") == 0) found_post = 1;
			if (found_post == 1)
				post.push_back(line);
		}

		int j=-1;
		while(std::getline(file, line))
		{
			data.push(line); // save the data before cleaning

			// clean the data to match case and remove punctuation
			char chars[] = ".,";
			for (unsigned int i = 0; i < strlen(chars); ++i)
			{
	      // you need include <algorithm> to use general algorithms like std::remove()
				line.erase (std::remove(line.begin(), line.end(), chars[i]), line.end());
			}
			std::transform(line.begin(), line.end(), line.begin(), ::tolower);
			j++;

		// cout << line << endl;
			istringstream ss(line);
			istream_iterator<string> begin(ss), end;

    //putting all the tokens in the vector
			vector<string> vec(begin, end);
			if (vec.size() >= 1)
			{
				if (vec[0].compare("nop") == 0)
				{
					result[j] = 0;
				}
				if (vec[0].compare("ret") == 0)
				{
					result[j] = OPCODE_RET;
				}
			}
			if (vec.size() >= 2)
			{
				if (vec[0].compare("in") == 0)
				{
					result[j] = OPCODE_IN;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
				}
				if (vec[0].compare("shl") == 0)
				{
					result[j] = OPCODE_SHL;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
				}
				if (vec[0].compare("shr") == 0)
				{
					result[j] = OPCODE_SHR;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
				}
				if (vec[0].compare("in") == 0)
				{
					result[j] = OPCODE_IN;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
				}
				if (vec[0].compare("out") == 0)
				{
					result[j] = OPCODE_OUT;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
				}
				if (vec[0].compare("br") == 0)
				{
					result[j] = OPCODE_BR;
					result[j] |= atoi(&(vec[1].c_str()[1]));
				}
				if (vec[0].compare("brn") == 0)
				{
					result[j] = OPCODE_BRN;
					result[j] |= atoi(&(vec[1].c_str()[1]));
				}
				if (vec[0].compare("brz") == 0)
				{
					result[j] = OPCODE_BRZ;
					result[j] |= atoi(&(vec[1].c_str()[1]));
				}
				if (vec[0].compare("brsub") == 0)
				{
					result[j] = OPCODE_BRSUB;
					result[j] |= atoi(&(vec[1].c_str()[1]));
				}

			}
			if (vec.size() >= 3)
			{
				if (vec[0].compare("add") == 0)
				{
					result[j] = OPCODE_ADD;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
					result[j] |= atoi(&(vec[2].c_str()[1]));
				}
				if (vec[0].compare("mov") == 0)
				{
					result[j] = OPCODE_MOV;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
					result[j] |= atoi(&(vec[2].c_str()[1]));
				}
				if (vec[0].compare("sub") == 0)
				{
					result[j] = OPCODE_SUB;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
					result[j] |= atoi(&(vec[2].c_str()[1]));
				}
				if (vec[0].compare("nand") == 0)
				{
					result[j] = OPCODE_NAND;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
					result[j] |= atoi(&(vec[2].c_str()[1]));
				}

				if (vec[0].compare("loadimm") == 0)
				{
					result[j] = OPCODE_LOADIMM;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
					result[++j] = atoi(vec[2].c_str()) & 0xff;
					data.push(vec[2]);
				}
				if (vec[0].compare("load") == 0)
				{
					result[j] = OPCODE_LOAD;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
					result[++j] = atoi(vec[2].c_str()) & 0xff;
				}
				if (vec[0].compare("store") == 0)
				{
					result[j] = OPCODE_STORE;
					result[j] |= atoi(&(vec[1].c_str()[1]))<<2;
					result[++j] = atoi(vec[2].c_str()) & 0xff;
				}
			}
		}

		int i=0;
		while((result[i] | result[i+1] | result[i+2] | result[i+3] | result[i+4] | result[i+5] | result[i+6] | result[i+7]) != 0)
		{
			printf("%i: 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n",
				i, result[i], result[i+1], result[i+2], result[i+3], result[i+4], result[i+5], result[i+6], result[i+7]);;
			i+=8;
		}
		int nops=0;
		int end=-1;
		for (end=127;end>=0;end--)
			if (result[end] != 0) break;

		std::ofstream outfile;
		if (!is_file_exist("imem_backup.vhd"))
		{
			cout << "imem_backup.vhd does not exist so copying imem.vhd there before we attempt to edit it" << endl;
			std::ifstream  src("imem.vhd", std::ios::binary);
			std::ofstream  dst("imem_backup.vhd",   std::ios::binary);
			dst << src.rdbuf();

		}
		cout << "Writing result to imem.vhd" << endl;
		outfile.open("imem.vhd");
		for (vector<string>::iterator it = pre.begin() ; it != pre.end(); ++it)
			outfile << *it << endl;

		for (int i=0;i<=end;i++)
		{
			string comment;
			if (data.size() > 0)
			{
				comment = data.front();
				data.pop();
			}
			else
				comment = "";
			std::bitset<8> bin(result[i]);
			outfile << "    x\"" << std::hex << std::setfill('0') << std::setw(2) << int(result[i]) << "\", -- " << bin << " " << comment << endl;
		}

		outfile << "    others => x\"00\"\n);\n";
for (vector<string>::iterator it = post.begin() ; it != post.end(); ++it)
	outfile << *it << endl;

}
