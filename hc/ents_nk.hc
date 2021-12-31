/*QUAKED obj_sign_left (0.3 0.1 0.6) (-10 -24 0) (10 24 60)
A wooden sign pointing to the left.
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void obj_sign_left()
{
	precache_model("models/sign_left.mdl");
	CreateEntityNew(self,ENT_SIGN_LEFT,"models/sign_left.mdl",chunk_death);
}

/*QUAKED obj_sign_right (0.3 0.1 0.6) (-10 -24 0) (10 24 60)
A wooden sign pointing to the right.
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void obj_sign_right()
{
	precache_model("models/sign_right.mdl");
	CreateEntityNew(self,ENT_SIGN_RIGHT,"models/sign_right.mdl",chunk_death);
}



/*QUAKED light_candle (0 1 0) (-7 -7 -15) (7 7 31) START_LOW
Default light value is 300
.health = If you give the torch health, it can be shot out.  It will automatically select it's second skin (the beat-up torch look)
You must give it a targetname too, just any junk targetname will do like "junk"
----------------------------------
If triggered, will toggle between lightvalue1 and lightvalue2
"lightvalue1" (default 0) 
"lightvalue2" (default 11, equivalent to 300 brightness)
"abslight" You can give it explicit lighting so it doesn't glow (0 to 2.5)
Two values the light will fade-toggle between, 0 is black, 25 is brightest, 11 is equivalent to a value of 300.
.fadespeed (default 1) = How many seconds it will take to complete the desired lighting change
The light will start on at a default of the higher light value unless you turn on the startlow flag.
START_LOW = will make the light start at the lower of the lightvalues you specify (default uses brighter)
NOTE: IF YOU DON'T PLAN ON USING THE DEFAULTS, ALL LIGHTS IN THE BANK OF LIGHTS NEED THIS INFO
--------------------------------------------------------
*/
void light_candle (void)
{
	precache_model4("models/candle.mdl");
	self.drawflags(+)MLS_ABSLIGHT;
	if(!self.abslight)
		self.abslight = .75;
	
	self.mdl = "models/candle.mdl";
	self.weaponmodel = "models/candle.mdl";	//FIXME: Flame On!
	
	self.thingtype	= THINGTYPE_BROWNSTONE;
	setsize(self, '-6 -6 -8','6 6 8');
	
	FireAmbient();
	Init_Torch();
	self.solid=SOLID_BBOX;
}

/*QUAKED obj_tankard
A tankard
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void obj_tankard()
{
	precache_model("models/tankard.mdl");
	CreateEntityNew(self,ENT_TANKARD,"models/tankard.mdl",chunk_death);
}

/*QUAKED obj_goblet
A goblet
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void obj_goblet()
{
	precache_model("models/goblet.mdl");
	CreateEntityNew(self,ENT_GOBLET,"models/goblet.mdl",chunk_death);
}

/*QUAKED obj_cleaver
A cleaver
-------------------------FIELDS-------------------------
none
--------------------------------------------------------
*/
void obj_cleaver()
{
	precache_model("models/cleaver.mdl");
	CreateEntityNew(self,ENT_CLEAVER,"models/cleaver.mdl",chunk_death);
}
