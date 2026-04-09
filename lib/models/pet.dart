class SpriteInfo {
  const SpriteInfo(this.fileName, this.frameCount);

  final String fileName;
  final int frameCount;
}

enum PetMood {
  idle('대기', 'self_improvement'),
  idle2('대기2', 'accessibility_new'),
  dance('춤', 'music_note'),
  eating('식사', 'restaurant'),
  excited('신남', 'celebration'),
  surprised('놀람', 'priority_high'),
  sad('슬픔', 'sentiment_dissatisfied'),
  cry('울기', 'water_drop'),
  sleepy('졸림', 'nights_stay'),
  sleep('수면', 'bedtime'),
  layDown('누움', 'airline_seat_flat'),
  waiting('기다림', 'hourglass_empty'),
  box1('박스1', 'inbox'),
  box2('박스2', 'inventory_2'),
  box3('박스3', 'archive'),
  dead('죽음', 'dangerous');

  const PetMood(this.label, this.iconName);

  final String label;
  final String iconName;
}

enum PetType {
  classicalCat(
    displayName: 'Classical Cat',
    basePath: 'assets/pets/cats/CatSprites/Classical/Individual',
    frameSize: 32,
  ),
  retroCat(
    displayName: 'Retro Cat',
    basePath: 'assets/pets/cats/RetroCats/Sprites',
    frameSize: 64,
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

const Map<PetType, Map<PetMood, SpriteInfo>> petSprites = {
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
    PetMood.dead: SpriteInfo('Dead', 1),
  },
};
