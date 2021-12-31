//Inky: custom function centerprint hiding the original one.
//Performs the same tasks + also logs the string in the console
void centerprint(entity client, string s)
{
	original_centerprint(client, s);
	sprint(client, s);
	sprint(client, "\n");
}

//Inky: 2-steps centerprint: writes a first message, then waits, then writes a second message
string secondstring;
void centerprint2b()
{
	centerprint(activator, secondstring);
	self.think = SUB_Null;
}

void centerprint2(string s1, string s2, float seconds)
{
	original_centerprint(activator, s1);
	//sprint(activator, s1);
	//sprint(activator, "\n");
	
	//Wait before the spell can be invoked again
	secondstring = s2;
	thinktime self : seconds;
	self.think = centerprint2b;
}

//Inky 20201217 just an alias for bprint used for debugging some code: more easy to retrieve afterwards for removal thanks to that special name
void jprint(string s)
{
	bprint(s);
}

void djprint(string s)
{
	dprint(s);
}

void ejprint(entity e)
{
	eprint(e);
}
