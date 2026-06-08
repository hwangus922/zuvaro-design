-- Seed data matching the iOS prototype (run after migrations)

insert into public.challenges (id, time_label, text, points, hook, minutes, rules, sort_order)
values
  (
    '00000000-0000-0000-0000-000000000001',
    '6 min',
    'Let yo bih go thru yo phone',
    20,
    'Oh hell naw jigsaw u tweaking bruh',
    6,
    'Hand your phone unlocked to someone in the room for 6 minutes. They can scroll anything except banking apps.',
    1
  ),
  (
    '00000000-0000-0000-0000-000000000002',
    '9 min',
    'Text your ex',
    10,
    'Yes.',
    9,
    'Send one honest text to your ex. No scheduling a call.',
    2
  ),
  (
    '00000000-0000-0000-0000-000000000003',
    '2 hrs',
    'Run 10 km',
    50,
    'Burn some calories',
    120,
    'Continuous run or walk. Strava / Apple Health / a sweaty selfie counts as proof.',
    3
  ),
  (
    '00000000-0000-0000-0000-000000000004',
    '5 hrs',
    'Larp having money',
    60,
    'Larp larp larp sahur',
    300,
    'Post a story flexing obvious fake wealth for at least 5 hours.',
    4
  ),
  (
    '00000000-0000-0000-0000-000000000005',
    '1 min',
    'Make a dumb joke',
    null,
    'Pure embarrassment',
    1,
    'Tell the joke out loud to at least two people. Groans = success.',
    5
  )
on conflict (id) do nothing;
