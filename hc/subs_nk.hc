//Punishes the player for a bad move by striking them with a lightning
void lightning_punish()
{
	local vector destination;
	local string temp;
	
	//Destination calculation
	destination = activator.origin;
	if (activator.hull==HULL_CROUCH)
		destination_z += 25;
	else
		destination_z += 53;

	traceline(self.origin,destination,TRUE,self);

	//Lightning
	do_lightning (self,5,STREAM_ATTACHED,4,self.origin,destination,0,TE_STREAM_LIGHTNING_SMALL);
	
	//Recoil
	activator.velocity+=normalize(v_forward)*-1000+normalize(v_up)*-300;
	
	if(activator.classname=="player")
	{
		//Damage
		T_Damage(activator,world,world,10);

		//Briefly troubled vision
		//stuffcmd(activator, "df");
		stuffcmd(activator, "v_cshift 255 0 0 200");
		
		//Cry
		StandardPain();
		
		//Message (if any)
		if(self.message && !deathmatch)
		{
			temp = getstring(self.message);
			centerprint(activator, temp);
		}		
	}
	else
	{
		//Super damage!
		T_Damage(activator,world,world,activator.max_health/3);
	}

}
