//$$---- EXE CPP ----
//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USEFORM("MainFormClass.cpp", MainForm);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	try
	{
		// check for the existence of the mutex.
     	HANDLE Mutex = OpenMutex(MUTEX_ALL_ACCESS, false, "OneInstanceAllowed");
		if (Mutex == NULL) // this is the only instance
		{
			//create the mutex...
			Mutex = CreateMutex(NULL, true, "OneInstanceAllowed");
		}
		else // this is not the only instance
		{
			return 0;
		}
		Application->Initialize();
		Application->ShowMainForm = false;
		Application->CreateForm(__classid(TMainForm), &MainForm);
		Application->Run();

        // release the mutex...
		ReleaseMutex(Mutex);
	}
	catch (Exception &exception)
	{
		Application->ShowException(&exception);
	}
	catch (...)
	{
		try
		{
			throw Exception("");
		}
		catch (Exception &exception)
		{
			Application->ShowException(&exception);
		}
	}
	return 0;
}
//---------------------------------------------------------------------------
