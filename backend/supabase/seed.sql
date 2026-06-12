-- Seed data — App Store–friendly challenge catalog

insert into public.challenges (id, time_label, text, points, hook, minutes, rules, sort_order)
values
  (
    '00000000-0000-0000-0000-000000000001',
    '5 min',
    'Give a genuine compliment',
    15,
    'Spread good vibes',
    5,
    'Compliment someone in person—a friend or a stranger. Submit a photo or short caption as proof.',
    1
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    '15 min',
    'Reach out to an old friend',
    20,
    'Reconnect',
    15,
    'Send a friendly text or voice note to someone you have not talked to in a while. Screenshot the message as proof.',
    2
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    '20 min',
    'Take a 20-minute walk',
    25,
    'Get moving',
    20,
    'Walk outside for at least 20 minutes. A photo of your route, step count, or a scenic shot counts as proof.',
    3
  ),
  (
    '00000000-0000-0000-0000-000000000004',
    '30 min',
    'Try a food you have never had',
    30,
    'Adventure bite',
    30,
    'Order or cook something new to you. Submit a photo with your dish.',
    4
  ),
  (
    '00000000-0000-0000-0000-000000000005',
    '1 min',
    'Tell a clean joke to two people',
    null,
    'Comedy hour',
    1,
    'Share a family-friendly joke with at least two people. Bonus points if they laugh.',
    5
  ),
  (
    '00000000-0000-0000-0000-000000000006',
    '10 min',
    'Let the crew pick your story post',
    35,
    'No takesies backsies',
    10,
    'Your group picks one photo from your camera roll. You post it to your story with zero context. Screenshot the story as proof.',
    6
  ),
  (
    '00000000-0000-0000-0000-000000000007',
    '5 min',
    'Send your crush a bold text',
    25,
    'Shoot your shot',
    5,
    'Send one flirty or chaotic text to someone you are into. Keep it consensual and playful—no harassment. Screenshot proof (blur names if you want).',
    7
  ),
  (
    '00000000-0000-0000-0000-000000000008',
    '3 min',
    'Hit the worm in public',
    30,
    'Main character energy',
    3,
    'Do the worm (or your best attempt) somewhere public—a park, store aisle, wherever. Video or photo proof required.',
    8
  ),
  (
    '00000000-0000-0000-0000-000000000009',
    '24 hrs',
    'Rock a crew-picked outfit',
    45,
    'Fashion victim arc',
    1440,
    'Let your crew vote on tomorrow''s fit. Wear it for at least 4 hours in public. Mirror selfie or street photo as proof.',
    9
  ),
  (
    '00000000-0000-0000-0000-000000000010',
    '15 min',
    'Voice note your worst hot take',
    20,
    'Unfiltered',
    15,
    'Record a 30-second voice note confessing your most unhinged (but harmless) opinion. Send it in the group chat or to a friend.',
    10
  ),
  (
    '00000000-0000-0000-0000-000000000011',
    '20 min',
    'Eat the cursed combo',
    40,
    'Chef''s kiss???',
    20,
    'Your crew picks two foods that should not go together. You eat a bite on camera. No allergens, no dangerous stuff—just weird.',
    11
  ),
  (
    '00000000-0000-0000-0000-000000000012',
    '10 min',
    'FaceTime lyrics only',
    20,
    'Broadway who?',
    10,
    'Call a friend and speak only in song lyrics for at least 2 minutes. They have to stay on the call. Screenshot or screen record.',
    12
  ),
  (
    '00000000-0000-0000-0000-000000000013',
    '1 hr',
    'Phone on the table, unlocked',
    50,
    'Trust fall but digital',
    60,
    'At dinner with friends, leave your phone face-up and unlocked on the table for 1 hour. They can look but not post or message. Photo of the setup counts.',
    13
  )
on conflict (id) do update set
  time_label = excluded.time_label,
  text = excluded.text,
  points = excluded.points,
  hook = excluded.hook,
  minutes = excluded.minutes,
  rules = excluded.rules,
  sort_order = excluded.sort_order;

-- Sponsors + sponsored challenge links (requires sponsors migration)
insert into public.sponsors (id, name, tagline, logo_emoji, website_url) values
  ('00000000-0000-0000-0000-000000000101', 'Pulse Energy', 'Fuel missions outside', '⚡', 'https://example.com/pulse'),
  ('00000000-0000-0000-0000-000000000102', 'Swift Sip Coffee', 'Show up caffeinated', '☕', 'https://example.com/swiftsip'),
  ('00000000-0000-0000-0000-000000000103', 'Trailhead Co.', 'Gear for real-world dares', '🥾', 'https://example.com/trailhead')
on conflict (id) do nothing;

update public.challenges
set sponsor_id = '00000000-0000-0000-0000-000000000103'
where id = '00000000-0000-0000-0000-000000000003';

update public.challenges
set sponsor_id = '00000000-0000-0000-0000-000000000102'
where id = '00000000-0000-0000-0000-000000000004';

update public.challenges
set sponsor_id = '00000000-0000-0000-0000-000000000101'
where id = '00000000-0000-0000-0000-000000000008';
