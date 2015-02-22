#include <stdio.h>

using namespace std;

int main(int argc, char** argv)
{
	if (argc <= 2)
	{
		cout << "Usage: " << argv[0] << " <infile> <outfile>" << endl << "If outfile ends in .txt the app will write ascii, otherwise binary" << endl;
		return 0;
	}
	cout << "asdf" << endl;
	return 0;
}