extends Node
## Sound effects synthesized at startup into 16-bit PCM buffers, so the project ships no audio files.
## Playback uses a small pool of players with per-sound rate limiting to keep 3x speed listenable.

const RATE := 22050
const POOL_SIZE := 16
const MIN_GAP_MS := 45

const MUSIC_BPM := 84.0
## Am - F - C - G - Am - F - G - E: (bass root, [triad]) as MIDI notes, one chord per bar.
const PROGRESSION := [
	[45, [57, 60, 64]], [41, [53, 57, 60]], [48, [55, 60, 64]], [43, [55, 59, 62]],
	[45, [57, 60, 64]], [41, [53, 57, 60]], [43, [55, 59, 62]], [40, [56, 59, 64]],
]
const ARP_PATTERN := [0, 1, 2, 1, 0, 2, 1, 2]

var streams := {}
var music: AudioStreamPlayer
var _players: Array = []
var _last := {}
var _rr := 0
var _rng := RandomNumberGenerator.new()
var _music_task := -1


func _ready() -> void:
	_rng.seed = 1337
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	add_child(music)
	_build_all()
	if DisplayServer.get_name() != "headless":
		_music_task = WorkerThreadPool.add_task(_compose_music_threaded, false, "compose music")


func _exit_tree() -> void:
	if _music_task != -1:
		WorkerThreadPool.wait_for_task_completion(_music_task)
		_music_task = -1


func _compose_music_threaded() -> void:
	var stream := _wav(compose_music())
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / 2
	_start_music.call_deferred(stream)


func _start_music(stream: AudioStreamWAV) -> void:
	if _music_task != -1:
		WorkerThreadPool.wait_for_task_completion(_music_task)
		_music_task = -1
	music.stream = stream
	music.volume_db = -60.0
	music.play()
	create_tween().tween_property(music, "volume_db", -6.0, 3.0)


## An 8-bar ambient loop: soft pad chords, a plucked bass, an 8th-note arpeggio and light percussion.
## Every note writes modulo the loop length, so tails wrap around and the loop is seamless.
func compose_music() -> PackedFloat32Array:
	var beat := 60.0 / MUSIC_BPM
	var bar := beat * 4.0
	var n := int(bar * PROGRESSION.size() * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	for b in PROGRESSION.size():
		var root: int = PROGRESSION[b][0]
		var triad: Array = PROGRESSION[b][1]
		var t0 := b * bar
		for note in triad:
			_add_note(out, t0, bar + 0.6, _midi(note), "pad", 0.045)
		for half in 2:
			_add_note(out, t0 + half * 2.0 * beat, beat * 1.9, _midi(root), "bass", 0.2)
		for step in 8:
			var tone: int = triad[ARP_PATTERN[step]] + 12
			var accent := 1.0 if step % 2 == 0 else 0.7
			_add_note(out, t0 + step * beat * 0.5, 0.45, _midi(tone), "pluck", 0.045 * accent)
		for k in 4:
			if k % 2 == 0:
				_add_note(out, t0 + k * beat, 0.25, 55.0, "kick", 0.22)
			_add_noise(out, t0 + (k + 0.5) * beat, 0.05, 0.018, rng)
	return out


static func _midi(m: int) -> float:
	return 440.0 * pow(2.0, (m - 69) / 12.0)


func _add_note(out: PackedFloat32Array, start: float, dur: float, freq: float, voice: String, vol: float) -> void:
	var n := out.size()
	var s0 := int(start * RATE)
	var count := int(dur * RATE)
	var phase := 0.0
	var phase2 := 0.0
	for i in count:
		var t := float(i) / RATE
		var v := 0.0
		match voice:
			"pad":
				phase += freq / RATE
				phase2 += freq * 1.004 / RATE
				var tri := 4.0 * absf(fmod(phase, 1.0) - 0.5) - 1.0
				var tri2 := 4.0 * absf(fmod(phase2, 1.0) - 0.5) - 1.0
				var env := minf(1.0, t / 0.5) * minf(1.0, (dur - t) / 0.6)
				v = (tri + tri2) * 0.5 * env
			"bass":
				phase += freq / RATE
				var s := sin(TAU * phase) + 0.25 * sin(TAU * phase * 2.0)
				v = s * exp(-t * 2.2) * minf(1.0, t / 0.01) * minf(1.0, (dur - t) / 0.05)
			"pluck":
				phase += freq / RATE
				v = (4.0 * absf(fmod(phase, 1.0) - 0.5) - 1.0) * exp(-t * 7.0) * minf(1.0, t / 0.004)
			"kick":
				phase += lerpf(freq * 1.6, freq * 0.7, minf(1.0, t / 0.12)) / RATE
				v = sin(TAU * phase) * exp(-t * 18.0) * minf(1.0, t / 0.002)
		out[(s0 + i) % n] += v * vol


func _add_noise(out: PackedFloat32Array, start: float, dur: float, vol: float, rng: RandomNumberGenerator) -> void:
	var n := out.size()
	var s0 := int(start * RATE)
	var prev := 0.0
	for i in int(dur * RATE):
		var t := float(i) / RATE
		var w := rng.randf_range(-1.0, 1.0)
		out[(s0 + i) % n] += (w - prev) * 0.5 * exp(-t * 60.0) * vol
		prev = w


func play(sound: String, volume_db := 0.0, pitch_jitter := 0.06) -> void:
	if not streams.has(sound):
		return
	var now := Time.get_ticks_msec()
	if now - int(_last.get(sound, -100000)) < MIN_GAP_MS:
		return
	_last[sound] = now
	var p := _free_player()
	p.stream = streams[sound]
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()


func _free_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	_rr = (_rr + 1) % _players.size()
	return _players[_rr]


func _build_all() -> void:
	streams["arrow"] = _wav(_mix([
		_tone(0.11, 1900.0, 380.0, 28.0, "square", 0.08),
		_tone(0.11, 1850.0, 360.0, 30.0, "sine", 0.18),
	]))
	streams["missile"] = _wav(_mix([
		_noise(0.35, 7.0, 0.5, 0.25),
		_tone(0.35, 220.0, 520.0, 6.0, "saw", 0.08),
	]))
	streams["laser"] = _wav(_mix([
		_tone(0.25, 700.0, 1400.0, 8.0, "square", 0.07),
		_tone(0.25, 1400.0, 2100.0, 9.0, "sine", 0.12),
	]))
	streams["cannon"] = _wav(_mix([
		_tone(0.2, 170.0, 60.0, 14.0, "sine", 0.7),
		_noise(0.12, 35.0, 0.35, 0.2),
	]))
	streams["boom"] = _wav(_mix([
		_tone(0.5, 90.0, 32.0, 7.0, "sine", 0.7),
		_noise(0.45, 8.0, 0.8, 0.08),
	]))
	streams["zap"] = _wav(_mix([
		_tone(0.16, 900.0, 500.0, 14.0, "square", 0.16, 0.35),
		_noise(0.14, 20.0, 0.18, 0.6),
	]))
	streams["frost"] = _wav(_mix([
		_tone(0.4, 1320.0, 1300.0, 8.0, "sine", 0.12),
		_tone(0.4, 1760.0, 1790.0, 9.0, "sine", 0.1),
		_tone(0.4, 2640.0, 2600.0, 11.0, "sine", 0.07),
	]))
	streams["sniper"] = _wav(_mix([
		_noise(0.1, 70.0, 0.9, 0.9),
		_tone(0.25, 2200.0, 700.0, 22.0, "sine", 0.25),
	]))
	streams["death"] = _wav(_tone(0.12, 520.0, 170.0, 18.0, "tri", 0.35))
	streams["boss_death"] = _wav(_mix([
		_tone(1.0, 110.0, 30.0, 3.5, "saw", 0.35),
		_noise(0.9, 4.0, 0.7, 0.06),
	]))
	streams["leak"] = _wav(_mix([
		_tone(0.32, 190.0, 150.0, 5.0, "square", 0.18),
		_tone(0.32, 142.0, 110.0, 5.0, "square", 0.14),
	]))
	streams["wave"] = _wav(_concat([
		_tone(0.2, 330.0, 330.0, 4.0, "saw", 0.22, 0.02),
		_tone(0.35, 440.0, 440.0, 4.0, "saw", 0.22, 0.02),
	]))
	streams["boss"] = _wav(_mix([
		_tone(1.1, 110.0, 104.0, 1.6, "saw", 0.26, 0.05),
		_tone(1.1, 165.0, 156.0, 1.6, "saw", 0.2, 0.05),
		_tone(1.1, 55.0, 52.0, 1.6, "sine", 0.4, 0.05),
	]))
	streams["click"] = _wav(_tone(0.035, 1500.0, 1200.0, 110.0, "sine", 0.35))
	streams["build"] = _wav(_mix([
		_tone(0.16, 420.0, 840.0, 12.0, "tri", 0.35),
		_noise(0.08, 40.0, 0.2, 0.3),
	]))
	streams["upgrade"] = _wav(_concat([
		_tone(0.08, 523.0, 523.0, 10.0, "tri", 0.3),
		_tone(0.08, 659.0, 659.0, 10.0, "tri", 0.3),
		_tone(0.2, 784.0, 784.0, 8.0, "tri", 0.32),
	]))
	streams["sell"] = _wav(_concat([
		_tone(0.07, 1320.0, 1320.0, 18.0, "sine", 0.3),
		_tone(0.16, 990.0, 990.0, 12.0, "sine", 0.3),
	]))
	streams["error"] = _wav(_concat([
		_tone(0.08, 180.0, 170.0, 8.0, "square", 0.16),
		_silence(0.04),
		_tone(0.1, 150.0, 140.0, 8.0, "square", 0.16),
	]))
	streams["heal"] = _wav(_tone(0.3, 660.0, 990.0, 7.0, "sine", 0.12, 0.03))
	streams["coin"] = _wav(_concat([
		_tone(0.05, 1568.0, 1568.0, 20.0, "sine", 0.22),
		_tone(0.12, 2093.0, 2093.0, 14.0, "sine", 0.22),
	]))
	streams["meteor_fall"] = _wav(_mix([
		_tone(0.9, 1400.0, 180.0, 1.2, "sine", 0.12, 0.2),
		_noise(0.9, 1.5, 0.25, 0.25),
	]))
	streams["meteor_impact"] = _wav(_mix([
		_tone(0.8, 75.0, 28.0, 4.5, "sine", 0.9),
		_noise(0.7, 5.0, 1.0, 0.06),
		_noise(0.12, 40.0, 0.4, 0.7),
	]))
	streams["warp"] = _wav(_mix([
		_tone(0.9, 900.0, 220.0, 2.0, "sine", 0.22, 0.02),
		_tone(0.9, 1350.0, 330.0, 2.5, "tri", 0.1, 0.02),
	]))
	streams["victory"] = _wav(_concat([
		_tone(0.16, 523.0, 523.0, 3.0, "tri", 0.32),
		_tone(0.16, 659.0, 659.0, 3.0, "tri", 0.32),
		_tone(0.16, 784.0, 784.0, 3.0, "tri", 0.32),
		_tone(0.7, 1047.0, 1047.0, 2.5, "tri", 0.34),
	]))
	streams["gameover"] = _wav(_concat([
		_tone(0.25, 392.0, 392.0, 3.0, "saw", 0.2),
		_tone(0.25, 311.0, 311.0, 3.0, "saw", 0.2),
		_tone(0.8, 196.0, 185.0, 2.0, "saw", 0.22),
	]))


# --- Synthesis -------------------------------------------------------------------------------

func _tone(dur: float, f0: float, f1: float, decay: float, shape: String, vol: float, attack := 0.004) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in n:
		var t := float(i) / RATE
		var p := t / dur
		phase += lerpf(f0, f1, p) / RATE
		var ph := fmod(phase, 1.0)
		var w := 0.0
		match shape:
			"sine":
				w = sin(TAU * ph)
			"square":
				w = 1.0 if ph < 0.5 else -1.0
			"saw":
				w = 2.0 * ph - 1.0
			_:
				w = 4.0 * absf(ph - 0.5) - 1.0
		var env := exp(-t * decay) * minf(1.0, t / attack) * minf(1.0, (dur - t) / 0.006)
		out[i] = w * env * vol
	return out


## Noise burst. `smooth` in (0, 1]: lower is a darker, rumblier sound.
func _noise(dur: float, decay: float, vol: float, smooth: float) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var s := 0.0
	var gain := 1.0 / sqrt(maxf(smooth, 0.02))
	for i in n:
		var t := float(i) / RATE
		s = lerpf(s, _rng.randf_range(-1.0, 1.0), smooth)
		var env := exp(-t * decay) * minf(1.0, t / 0.003) * minf(1.0, (dur - t) / 0.006)
		out[i] = s * env * vol * gain * 0.5
	return out


func _silence(dur: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(dur * RATE))
	return out


func _mix(parts: Array) -> PackedFloat32Array:
	var n := 0
	for p in parts:
		n = maxi(n, p.size())
	var out := PackedFloat32Array()
	out.resize(n)
	for p in parts:
		var arr: PackedFloat32Array = p
		for i in arr.size():
			out[i] += arr[i]
	return out


func _concat(parts: Array) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	for p in parts:
		out.append_array(p)
	return out


func _wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = bytes
	return s
