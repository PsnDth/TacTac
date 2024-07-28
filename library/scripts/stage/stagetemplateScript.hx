// API Script for Tac Tac

var leftPlat = null;
var rightPlat = null;
var is_f1 = true;
var tac_handlers = [];

// Just a simple version of Point, that should not have the memory concerns
var SafePoint = {
	create: function(?x: Int = 0, ?y: Int = 0) {
		var me;
		me = {
			x: x, 
			y: y,
			// Can add methods as needed
			add: (other) -> SafePoint.create(me.x + other.x, me.y + other.y),
			sub: (other) -> SafePoint.create(me.x - other.x, me.y - other.y),
			div: (num) -> SafePoint.create(me.x/num, me.y/num),
		};
		return me;
	},
};

// Handle how the different plats move
var PlatMovementHandler = {
	MotionType: {
		LINEAR: 0,
		EASE: 1,
		// could also add curves and what not
	},
	create: function (struct: Structure, path:Array<Dynamic>) {
		// Path should be a list of structs, each struct should specify {pos: point, motion_type: MotionType, travel_time: number, rest_time: number}
		if (path.length == 0) return {
			_path: path,
			_struct: struct,
			disable: function() {}, // public function does nothing
		};

		// Put struct in initial position
		struct.setX(path[0].pos.x);
		struct.setY(path[0].pos.y);
		var me;
		me = {
			_path: path,
			_struct: struct,
			_path_pos: 0,
			_resting: true,
			_rest_time: 0,
			_travelling: false,
			_travel_time: path[0].travel_time,
			_prev_pos: null,


			_increment_path_state: function() {
				var curr_elem = me._path[me._path_pos];
				// set pos if incrementing
				me._struct.setX(curr_elem.pos.x);
				me._struct.setY(curr_elem.pos.y);
				
				if (me._travelling && curr_elem.rest_time > 0) {
					me._rest_time = 0;
					me._travel_time = 0;
					me._resting = true;
					me._travelling = false;
					// prevpos not needed
					return;
				}
				// otherwise if resting or no rest time needed, then should go to next elem
				me._path_pos = (me._path_pos + 1) % me._path.length;
				curr_elem = me._path[me._path_pos];
				// set to travelling unless travel_time == 0
				should_rest = curr_elem.travel_time == 0;
				me._resting = should_rest;
				me._travelling = !should_rest;
				me._prev_pos = SafePoint.create(me._struct.getX(), me._struct.getY());
				me._travel_time = 0;
				me._rest_time = 0;
			},
			_tick: function() {
				var path_elem = me._path[me._path_pos];
				if (me._resting) {
					me._rest_time += 1;
					if (me._rest_time == path_elem.rest_time) {
						me._increment_path_state();
						return;
					}
				}
				if (me._travelling) {
					if (path_elem.motion_type != PlatMovementHandler.MotionType.LINEAR) Engine.log("Found non-linear motion type, only linear supported for now");
					var speed = path_elem.pos.sub(me._prev_pos).div(path_elem.travel_time);
					me._struct.setX(me._struct.getX() + speed.x);
					me._struct.setY(me._struct.getY() + speed.y);
					me._travel_time += 1;
					if (me._travel_time == path_elem.travel_time) {
						me._increment_path_state();
						return;
					}
				}
			},
			disable: function() {
				me._resting = false;
				me._travelling = false;
				me._path_pos = 0;
				me._rest_time = 0;
				me._travel_time = 0;
				me._prev_pos = null;

				var curr_elem = me._path[me._path_pos];
				// set pos if incrementing
				me._struct.setX(curr_elem.pos.x);
				me._struct.setY(curr_elem.pos.y);
			}


		};
		match.addEventListener(MatchEvent.TICK_START, me._tick);
		return me;
	},
};

var TacHandler = {
	AIR_CANCELLED_STATE: CState.FALL,
	GROUND_CANCELLED_STATE: CState.STAND,
	// black list
	UNCANCELLABLE_GROUPS: [CStateGroup.SHIELD, CStateGroup.AIRDASH, CStateGroup.KO, CStateGroup.LEDGE,],
	UNCANCELLABLE_STATES: [CState.INTRO, CState.HELD, CState.TUMBLE, CState.DASH, CState.DASH_PIVOT, CState.JUMP_SQUAT, CState.STAND, CState.STAND_TURN, CState.GRAB_HOLD/* inHurtState*/],
	// white list (overrides black list)
	CANCELLABLE_STATES: [CState.LEDGE_ATTACK],
	// meter free states (whitelist)
	METER_FREE_STATES: [CState.PARRY_SUCCESS],
	// meter cancel states (blacklist)
	METER_CANCEL_GROUPS: [CStateGroup.ATTACK, CStateGroup.LEDGE_CLIMB, CStateGroup.LEDGE_ROLL, CStateGroup.PARRY],
	METER_CANCEL_STATES: [CState.GRAB, CState.FALL_SPECIAL, CState.ROLL, CState.SPOT_DODGE, /* airdash_land_whiff */],

	MAX_CANCELS: 4,
	NORMAL_COOLDOWN: 45,
	MAX_COOLDOWN: 45 * 4,
	init: function(player: Character) {
		var me;
		me  = {
			_hud_sprite: null,
			_cancels_used: 0,
			_time_since_last_cancel: 0,
			_can_free_cancel: false,

			allowFreeCancels: function() {
				me._can_free_cancel = true;
			},
			_init: function() {
				player.addTimer(1, -1, me._tick, {persistent: true});
				match.addEventListener(ScoreEvent.PARRY, function(e: ScoreEvent) {
					if (e.data.self == player) me._onParry();
				}, {persistent: true});
				me._hud_sprite = Sprite.create(self.getResource().getContent("tactac"));
				me._hud_sprite.currentAnimation = "hud";
				me._hud_sprite.alpha = 0.7;
				player.getDamageCounterContainer().addChild(me._hud_sprite);
			},
			_onParry: function() {
				me._cancels_used = Math.max(me._cancels_used - 1, 0);
				me._time_since_last_cancel = 0;
			},
			_tick: function() {
				// Give back meter on death
				if (player.inState(CState.KO)) me._cancels_used = 0;
				
				if (!me._tryCancel() && me._cancels_used > 0) {
					var cooldown = me._cancels_used < TacHandler.MAX_CANCELS ? TacHandler.NORMAL_COOLDOWN : TacHandler.MAX_COOLDOWN;
					var amount_restored = me._cancels_used < TacHandler.MAX_CANCELS ? 1 : 4; // give all cancels back if waited full cooldown
					me._time_since_last_cancel += 1;
					if (me._time_since_last_cancel >= cooldown) {
						me._cancels_used -= amount_restored;
						me._time_since_last_cancel = 0;
					}
				}
				me._hud_sprite.currentFrame = me._cancels_used + 1;
			},
			_didInputCancel: function() {
				var pressed = player.getPressedControls();
				var pressed_dir = pressed.LEFT || pressed.RIGHT;
				var pressed_fwd = (pressed.LEFT != player.isFacingLeft()) || (pressed.RIGHT != player.isFacingRight());
				return pressed_dir && pressed_fwd;
			},
			_resetResources: function() {
				var jump_count = player.getDoubleJumpCount();
				var ad_count = player.getAirdashCount();
				player.preLand();
				player.setAirdashCount(ad_count);
				player.setDoubleJumpCount(jump_count);
				var disabled_actions = player.getStatusEffectByType(StatusEffectType.DISABLE_ACTION);
				if (disabled_actions == null) return;
				for (status_effect in disabled_actions.values) {
					player.removeStatusEffect(StatusEffectType.DISABLE_ACTION, status_effect.id);
				}
			},
			_inCancellableState: function() {
				if (TacHandler.CANCELLABLE_STATES.contains(player.getState())) return true;
				if (TacHandler.UNCANCELLABLE_STATES.contains(player.getState())) return false;
				if (player.inHurtState()) return false;
				for (state_group in TacHandler.UNCANCELLABLE_GROUPS) {
					if (player.inStateGroup(state_group)) return false;
				}
				return true;
			},
			_shouldConsumeCancel: function() {
				if (me._can_free_cancel) return false;
				if (TacHandler.METER_FREE_STATES.contains(player.getState())) return false;
				if (TacHandler.METER_CANCEL_STATES.contains(player.getState())) return true;
				for (state_group in TacHandler.METER_CANCEL_GROUPS) {
					if (player.inStateGroup(state_group)) return true;
				}
				// if in airdash cancelled > land 
				if (player.inState(CState.LAND) && player.getAnimation() == "airdash_land_whiff") return true;
				return false;
			},
			_tryCancel: function() {
				if (me._cancels_used >= TacHandler.MAX_CANCELS) return false;
				if (!me._inCancellableState()) return false;
				if (!me._didInputCancel()) return false;
				if (me._shouldConsumeCancel()) {
					me._cancels_used += 1;
					me._time_since_last_cancel = 0;
				}
				player.releaseAllCharacters();
				player.flip();
				if (player.getHitstop() > 0) player.forceStartHitstop(0);
				if (me._can_free_cancel) me._resetResources();
				player.toState(player.isOnFloor() ? TacHandler.GROUND_CANCELLED_STATE : TacHandler.AIR_CANCELLED_STATE);
				return true;
			},
		};
		me._init();
		return me;
	},
};

function initialize(){
	// Don't animate the stage itself (we'll pause on one version for hazards on, and another version for hazards off)
	self.pause();

	// Floor X(-415 -> 429), Y(70)
	leftPlat = PlatMovementHandler.create(match.createStructure(self.getResource().getContent("tactacMovingPlatform")), [
		{
			pos: SafePoint.create(-415 +100 + 75, -60),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 10*60,
			rest_time: 45*60,
		},
		{
			pos: SafePoint.create(-415 -100 -75, -60),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 7.5*60,
			rest_time: 15*60,
		},
		{
			pos: SafePoint.create(-415 -25 -75, 250),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 7.5*60,
			rest_time: 1*60,
		},
		{
			pos: SafePoint.create(-415 -100 -75, -60),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 10*60,
			rest_time: 15*60,
		},
	]);
	rightPlat = PlatMovementHandler.create(match.createStructure(self.getResource().getContent("tactacMovingPlatform")), [
		{
			pos: SafePoint.create(429 -100 -75, -60),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 10*60,
			rest_time: 45*60,
		},
		{
			pos: SafePoint.create(429 +100 +75, -60),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 7.5*60,
			rest_time: 15*60,
		},
		{
			pos: SafePoint.create(429 +25 +75, 250),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 7.5*60,
			rest_time: 1*60,
		},
		{
			pos: SafePoint.create(429 +100 +75, -60),
			motion_type: PlatMovementHandler.MotionType.LINEAR,
			travel_time: 10*60,
			rest_time: 15*60,
		},
	]);

}

function update(){
	for (player in match.getPlayers()) {
		if (is_f1) {
			if (player.getPlayerConfig().port != 0) {
				player.setVisible(false);
				player.getDamageCounterContainer().visible = false;
				player.toState(CState.DISABLED);
			} else {
				player.getDamageCounterContainer().x += 115;
			}
		}
		if (is_f1 && match.getMatchSettingsConfig().hazards) {
			tac_handlers.push(TacHandler.init(player));
		}
		if (!player.inState(CState.INTRO)) continue;
		var held_controls: ControlsObject = player.getHeldControls();
		if ((held_controls.ACTION || held_controls.EMOTE) && held_controls.GRAB) {
			leftPlat.disable();
			rightPlat.disable();
		}
		if ((held_controls.ACTION || held_controls.EMOTE) && held_controls.SPECIAL) {
			for (handler in tac_handlers) {
				handler.allowFreeCancels();
			}
		}
	}
	is_f1 = false;
}

function onTeardown(){
}

// Time: roughly 7h + 4h


// TODO:
// - backgrounds/parallax/camera

// TODO (maybe later):
// - tweak cancel cooldown of 4th cancel
// - no limits mode (give back resources, no meter)
// - rollback support