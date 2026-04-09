class SpriteInfo {
  const SpriteInfo(this.fileName, this.frameCount);

  final String fileName;
  final int frameCount;
}

enum PetMood {
  idle('대기'),
  idle2('대기2'),
  dance('춤'),
  eating('식사'),
  excited('신남'),
  surprised('놀람'),
  sad('슬픔'),
  cry('울기'),
  sleepy('졸림'),
  sleep('수면'),
  layDown('누움'),
  waiting('기다림'),
  sitting('앉기'),
  running('달리기'),
  jumping('점프'),
  walking('걷기'),
  flying('비행'),
  barking('짖기'),
  sniffing('킁킁'),
  attack('공격'),
  hurt('아픔'),
  liking('좋아함'),
  box1('박스1'),
  box2('박스2'),
  box3('박스3'),
  dead('죽음');

  const PetMood(this.label);

  final String label;
}

enum PetType {
  // Cats
  classicalCat(
    displayName: 'Classical Cat',
    basePath: 'assets/pets/cats/CatSprites/Classical/Individual',
    frameSize: 32,
  ),
  retroCat(
    displayName: 'Retro Cat',
    basePath: 'assets/pets/cats/RetroCats/Sprites',
    frameSize: 64,
  ),

  // Dogs
  labrador(
    displayName: 'Labrador',
    basePath: 'assets/pets/dogs/Labrador/Sprites',
    frameSize: 64,
  ),
  golden(
    displayName: 'Golden',
    basePath: 'assets/pets/dogs/Golden',
    frameSize: 64,
  ),
  husky(
    displayName: 'Husky',
    basePath: 'assets/pets/dogs/Husky',
    frameSize: 64,
  ),
  dalmatian(
    displayName: 'Dalmatian',
    basePath: 'assets/pets/dogs/Dalmatian',
    frameSize: 64,
  ),
  caneCorso(
    displayName: 'Cane Corso',
    basePath: 'assets/pets/dogs/CaneCorso',
    frameSize: 64,
  ),
  dogoArgentino(
    displayName: 'Dogo Argentino',
    basePath: 'assets/pets/dogs/DogoArgentino',
    frameSize: 64,
  ),
  pharaohHound(
    displayName: 'Pharaoh Hound',
    basePath: 'assets/pets/dogs/LittlePharaoh Hound',
    frameSize: 64,
  ),

  // Bunnies
  bunnyBrown(
    displayName: 'Brown Bunny',
    basePath: 'assets/pets/bunnies/BunnyBrown',
    frameSize: 32,
  ),
  bunnyBlack(
    displayName: 'Black Bunny',
    basePath: 'assets/pets/bunnies/BunnyBlack',
    frameSize: 32,
  ),
  bunnyWhite(
    displayName: 'White Bunny',
    basePath: 'assets/pets/bunnies/WhiteBunny',
    frameSize: 32,
  ),
  bunnyGrey(
    displayName: 'Grey Bunny',
    basePath: 'assets/pets/bunnies/GreyBunny',
    frameSize: 32,
  ),
  bunnyBlackWhite(
    displayName: 'Black&White Bunny',
    basePath: 'assets/pets/bunnies/BlackWhite',
    frameSize: 32,
  ),
  bunnyBrownWhite(
    displayName: 'Brown&White Bunny',
    basePath: 'assets/pets/bunnies/BrownWhite',
    frameSize: 32,
  ),
  bunnyBrown2Color(
    displayName: 'Two-Tone Bunny',
    basePath: 'assets/pets/bunnies/Brown2Color',
    frameSize: 32,
  ),
  bunnyLightBrown(
    displayName: 'Light Brown Bunny',
    basePath: 'assets/pets/bunnies/LightBrown',
    frameSize: 32,
  ),
  bunnyDemonic(
    displayName: 'Demonic Bunny',
    basePath: 'assets/pets/bunnies/DemonicBunny',
    frameSize: 32,
  ),
  bunnyFantasy(
    displayName: 'Fantasy Bunny',
    basePath: 'assets/pets/bunnies/FantasyBunny',
    frameSize: 32,
  ),

  // Birds
  birdBlack(
    displayName: 'Black Bird',
    basePath: 'assets/pets/bird/Birds/Black',
    frameSize: 16,
  ),
  birdBlue(
    displayName: 'Blue Bird',
    basePath: 'assets/pets/bird/Birds/Blue',
    frameSize: 16,
  ),
  birdGreen(
    displayName: 'Green Bird',
    basePath: 'assets/pets/bird/Birds/Green',
    frameSize: 16,
  ),
  birdOrange(
    displayName: 'Orange Bird',
    basePath: 'assets/pets/bird/Birds/Orange',
    frameSize: 16,
  ),
  birdPink(
    displayName: 'Pink Bird',
    basePath: 'assets/pets/bird/Birds/Pink',
    frameSize: 16,
  ),
  birdPurple(
    displayName: 'Purple Bird',
    basePath: 'assets/pets/bird/Birds/Purple',
    frameSize: 16,
  ),
  birdWhite(
    displayName: 'White Bird',
    basePath: 'assets/pets/bird/Birds/White',
    frameSize: 16,
  ),
  birdYellow(
    displayName: 'Yellow Bird',
    basePath: 'assets/pets/bird/Birds/Yellow',
    frameSize: 16,
  ),

  // Parrots
  parrot1(
    displayName: 'Parrot 1',
    basePath: 'assets/pets/bird/Parrot/Parrot1',
    frameSize: 16,
  ),
  parrot2(
    displayName: 'Parrot 2',
    basePath: 'assets/pets/bird/Parrot/Parrot2',
    frameSize: 16,
  ),
  parrot3(
    displayName: 'Parrot 3',
    basePath: 'assets/pets/bird/Parrot/Parrot3',
    frameSize: 16,
  ),
  parrot4(
    displayName: 'Parrot 4',
    basePath: 'assets/pets/bird/Parrot/Parrot4',
    frameSize: 16,
  ),
  parrot5(
    displayName: 'Parrot 5',
    basePath: 'assets/pets/bird/Parrot/Parrot5',
    frameSize: 16,
  );

  const PetType({
    required this.displayName,
    required this.basePath,
    required this.frameSize,
  });

  final String displayName;
  final String basePath;
  final int frameSize;

  String spritePath(String fileName) => '$basePath/$fileName.png';
}

// ── Sprite mappings ─────────────────────────────────────────────────

const Map<PetType, Map<PetMood, SpriteInfo>> petSprites = {
  // ── Cats ──
  PetType.classicalCat: {
    PetMood.idle: SpriteInfo('Idle', 10),
    PetMood.idle2: SpriteInfo('Idle2', 10),
    PetMood.dance: SpriteInfo('Dance', 4),
    PetMood.eating: SpriteInfo('Eating', 15),
    PetMood.excited: SpriteInfo('Excited', 12),
    PetMood.surprised: SpriteInfo('Surprised', 12),
    PetMood.sad: SpriteInfo('Sad', 9),
    PetMood.cry: SpriteInfo('Cry', 4),
    PetMood.sleepy: SpriteInfo('Sleepy', 8),
    PetMood.sleep: SpriteInfo('Sleep', 4),
    PetMood.layDown: SpriteInfo('LayDown', 12),
    PetMood.waiting: SpriteInfo('Waiting', 6),
    PetMood.box1: SpriteInfo('Box1', 4),
    PetMood.box2: SpriteInfo('Box2', 12),
    PetMood.box3: SpriteInfo('Box3', 4),
    PetMood.dead: SpriteInfo('DeadCat', 1),
  },
  PetType.retroCat: {
    PetMood.idle: SpriteInfo('Idle', 6),
    PetMood.dance: SpriteInfo('Dance', 4),
    PetMood.eating: SpriteInfo('Happy', 10),
    PetMood.excited: SpriteInfo('Excited', 3),
    PetMood.surprised: SpriteInfo('Surprised', 4),
    PetMood.sad: SpriteInfo('Crying', 4),
    PetMood.sleep: SpriteInfo('Sleeping', 4),
    PetMood.running: SpriteInfo('Running', 6),
    PetMood.jumping: SpriteInfo('Jump', 12),
    PetMood.attack: SpriteInfo('Attack', 7),
    PetMood.hurt: SpriteInfo('Hurt', 8),
    PetMood.dead: SpriteInfo('Dead', 1),
  },

  // ── Dogs ──
  PetType.labrador: {
    PetMood.idle: SpriteInfo('Idle', 6),
    PetMood.attack: SpriteInfo('Attack', 16),
    PetMood.barking: SpriteInfo('Bark', 16),
    PetMood.running: SpriteInfo('Run', 16),
    PetMood.sitting: SpriteInfo('Sitting', 16),
    PetMood.layDown: SpriteInfo('Laydown', 16),
    PetMood.sleep: SpriteInfo('Sleeping', 16),
    PetMood.sniffing: SpriteInfo('Sniff', 16),
    PetMood.hurt: SpriteInfo('Hurt', 16),
    PetMood.dead: SpriteInfo('Die', 16),
  },
  PetType.golden: {
    PetMood.idle: SpriteInfo('GoldenIdle', 10),
    PetMood.attack: SpriteInfo('GoldenAttack', 17),
    PetMood.barking: SpriteInfo('GoldenBarking', 11),
    PetMood.running: SpriteInfo('RunDog', 6),
    PetMood.sitting: SpriteInfo('Sitting', 8),
    PetMood.layDown: SpriteInfo('LieDown', 12),
    PetMood.sleep: SpriteInfo('SleepDog', 8),
    PetMood.sniffing: SpriteInfo('GoldenSniff', 29),
    PetMood.hurt: SpriteInfo('GoldenHurt', 15),
    PetMood.dead: SpriteInfo('GoldenDie', 15),
  },
  PetType.husky: {
    PetMood.idle: SpriteInfo('HuskyIdle', 6),
    PetMood.attack: SpriteInfo('HuskyAttack', 15),
    PetMood.barking: SpriteInfo('Huskybark', 10),
    PetMood.running: SpriteInfo('HuskyRun', 6),
    PetMood.sitting: SpriteInfo('HuskySitting', 8),
    PetMood.layDown: SpriteInfo('HuskyLieDown', 12),
    PetMood.sleep: SpriteInfo('HuskySleep', 8),
    PetMood.sniffing: SpriteInfo('HuskySniff', 24),
    PetMood.hurt: SpriteInfo('HuskyHurt', 15),
    PetMood.dead: SpriteInfo('HuskyDie', 18),
  },
  PetType.dalmatian: {
    PetMood.idle: SpriteInfo('IdleDog', 7),
    PetMood.attack: SpriteInfo('AttackDog', 16),
    PetMood.barking: SpriteInfo('BarkDog', 12),
    PetMood.running: SpriteInfo('RunDog', 5),
    PetMood.sitting: SpriteInfo('Sitting', 8),
    PetMood.layDown: SpriteInfo('LieDown', 12),
    PetMood.sleep: SpriteInfo('SleepDog', 8),
    PetMood.sniffing: SpriteInfo('SniffDog', 26),
    PetMood.hurt: SpriteInfo('HurtDog-sheet', 15),
    PetMood.dead: SpriteInfo('DieDog', 11),
  },
  PetType.caneCorso: {
    PetMood.idle: SpriteInfo('IdleDog', 7),
    PetMood.attack: SpriteInfo('AttackDog', 16),
    PetMood.barking: SpriteInfo('BarkingDog', 9),
    PetMood.running: SpriteInfo('RunDog', 7),
    PetMood.sitting: SpriteInfo('Sitting', 7),
    PetMood.layDown: SpriteInfo('LieDown', 7),
    PetMood.sleep: SpriteInfo('SleepDog', 3),
    PetMood.sniffing: SpriteInfo('SniffDog', 12),
    PetMood.hurt: SpriteInfo('HurtDog', 6),
    PetMood.dead: SpriteInfo('DieDog', 10),
  },
  PetType.dogoArgentino: {
    PetMood.idle: SpriteInfo('IdleDog', 7),
    PetMood.attack: SpriteInfo('AttackDogo', 16),
    PetMood.barking: SpriteInfo('BarkDogo', 9),
    PetMood.running: SpriteInfo('RunDogo', 7),
    PetMood.sitting: SpriteInfo('SittingDogo', 7),
    PetMood.layDown: SpriteInfo('LieDownDogo', 7),
    PetMood.sleep: SpriteInfo('SleepingDogo', 3),
    PetMood.sniffing: SpriteInfo('SniffDogo', 12),
    PetMood.hurt: SpriteInfo('HurtDogo', 6),
    PetMood.dead: SpriteInfo('DieDogo', 10),
  },
  PetType.pharaohHound: {
    PetMood.idle: SpriteInfo('Idle', 6),
    PetMood.attack: SpriteInfo('Bite', 11),
    PetMood.barking: SpriteInfo('Barking', 9),
    PetMood.eating: SpriteInfo('Eating', 15),
    PetMood.running: SpriteInfo('Run', 6),
    PetMood.sitting: SpriteInfo('Sitting', 8),
    PetMood.layDown: SpriteInfo('LayDown', 8),
    PetMood.sleep: SpriteInfo('Sleeping', 8),
    PetMood.hurt: SpriteInfo('Hurt', 10),
    PetMood.dead: SpriteInfo('Die', 8),
  },

  // ── Bunnies (all share the same sprite names) ──
  PetType.bunnyBrown: _bunnySprites,
  PetType.bunnyBlack: _bunnySprites,
  PetType.bunnyWhite: _bunnySprites,
  PetType.bunnyGrey: _bunnySprites,
  PetType.bunnyBlackWhite: _bunnySprites,
  PetType.bunnyBrownWhite: _bunnySprites,
  PetType.bunnyBrown2Color: _bunnySprites,
  PetType.bunnyLightBrown: _bunnySprites,
  PetType.bunnyDemonic: _bunnySprites,
  PetType.bunnyFantasy: _bunnySprites,

  // ── Birds (all share the same sprite names) ──
  PetType.birdBlack: _birdSprites,
  PetType.birdBlue: _birdSprites,
  PetType.birdGreen: _birdSprites,
  PetType.birdOrange: _birdSprites,
  PetType.birdPink: _birdSprites,
  PetType.birdPurple: _birdSprites,
  PetType.birdWhite: _birdSprites,
  PetType.birdYellow: _birdSprites,

  // ── Parrots ──
  PetType.parrot1: _parrot1Sprites,
  PetType.parrot2: _parrotSprites,
  PetType.parrot3: _parrotSprites,
  PetType.parrot4: _parrotSprites,
  PetType.parrot5: _parrotSprites,
};

const _bunnySprites = <PetMood, SpriteInfo>{
  PetMood.idle: SpriteInfo('Idle', 12),
  PetMood.attack: SpriteInfo('Attack', 9),
  PetMood.running: SpriteInfo('Running', 8),
  PetMood.jumping: SpriteInfo('Jumping', 11),
  PetMood.liking: SpriteInfo('Liking', 5),
  PetMood.layDown: SpriteInfo('LieDown', 6),
  PetMood.sleep: SpriteInfo('Sleep', 6),
  PetMood.hurt: SpriteInfo('HurtIdle', 8),
  PetMood.dead: SpriteInfo('Death', 12),
};

const _birdSprites = <PetMood, SpriteInfo>{
  PetMood.idle: SpriteInfo('IdleBird', 6),
  PetMood.attack: SpriteInfo('BirdAttack', 6),
  PetMood.flying: SpriteInfo('BirdFly', 8),
  PetMood.walking: SpriteInfo('BirdWalk', 6),
  PetMood.sitting: SpriteInfo('BirdSit', 6),
  PetMood.sleep: SpriteInfo('BirdSleep', 8),
  PetMood.hurt: SpriteInfo('BirdHurt', 12),
  PetMood.dead: SpriteInfo('BirdDie', 10),
};

const _parrot1Sprites = <PetMood, SpriteInfo>{
  PetMood.idle: SpriteInfo('ParrotBird', 6),
  PetMood.attack: SpriteInfo('ParrotAttack', 6),
  PetMood.flying: SpriteInfo('ParrotFly', 8),
  PetMood.walking: SpriteInfo('ParrotWalk', 6),
  PetMood.sitting: SpriteInfo('ParrotSitting', 6),
  PetMood.sleep: SpriteInfo('ParrotSleep', 8),
  PetMood.hurt: SpriteInfo('ParrotHurt', 12),
  PetMood.dead: SpriteInfo('ParrotDie', 10),
};

const _parrotSprites = <PetMood, SpriteInfo>{
  PetMood.idle: SpriteInfo('Idle', 6),
  PetMood.attack: SpriteInfo('Attack', 6),
  PetMood.flying: SpriteInfo('Fly', 8),
  PetMood.walking: SpriteInfo('Walk', 6),
  PetMood.sitting: SpriteInfo('Sitting', 6),
  PetMood.sleep: SpriteInfo('Sleeping', 8),
  PetMood.hurt: SpriteInfo('Hurt', 12),
  PetMood.dead: SpriteInfo('Die', 10),
};
