function mapthing_damage(damage, victim) {
	victim.levelThingInfo.HP -= damage;
	
	if (victim.levelThingInfo.HP < 0) {
		mapthing_kill(victim);
	}
	
	if (victim.levelThingInfo.HP > 0) and (mapthing_has_flag(victim, Flags.MT_PLAYER)) {
		broadcast(Messages.PLAYER_DAMAGED);
	}
}

function mapthing_kill(mt) {
	instance_destroy(mt);
}

function mapthing_try_fake_bounce(mt) {
	with (mt) {
		if (zPos == 0) {
			if (isGrounded and (moveH != 0 or moveV != 0)) {
				if (bounceIsGrounded) {
					bounceZVel = bounceStrength;
					bounceIsGrounded = false;
			            
			            	audio_play_sound(soundJohnBounce, 100, false);
					mapthing_squash(self, -0.10, 0.10, 100);
				}
				
			} else {
				
			        if (bounceZPos == 0 and bounceZVel == 0) {
						bounceIsGrounded = true;
					}
			}
		    
			if (!bounceIsGrounded) {
				bounceZVel -= (gravityZ - 0.2);
				bounceZPos += bounceZVel;
				
				if (bounceZPos <= 0) {
					bounceZPos = 0;
					bounceZVel = 0;
					bounceIsGrounded = true;
				}
			}	
		}
		
		fakeBounceOffset = bounceZPos;
	
	}
}

