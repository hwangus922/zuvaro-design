-- App Store–friendly challenge catalog (replaces edgy seed content).

update public.challenges set
  time_label = '5 min',
  text = 'Give a genuine compliment',
  points = 15,
  hook = 'Spread good vibes',
  minutes = 5,
  rules = 'Compliment someone in person—a friend or a stranger. Submit a photo or short caption as proof.',
  sort_order = 1
where id = '00000000-0000-0000-0000-000000000001';

update public.challenges set
  time_label = '15 min',
  text = 'Reach out to an old friend',
  points = 20,
  hook = 'Reconnect',
  minutes = 15,
  rules = 'Send a friendly text or voice note to someone you have not talked to in a while. Screenshot the message as proof.',
  sort_order = 2
where id = '00000000-0000-0000-0000-000000000002';

update public.challenges set
  time_label = '20 min',
  text = 'Take a 20-minute walk',
  points = 25,
  hook = 'Get moving',
  minutes = 20,
  rules = 'Walk outside for at least 20 minutes. A photo of your route, step count, or a scenic shot counts as proof.',
  sort_order = 3
where id = '00000000-0000-0000-0000-000000000003';

update public.challenges set
  time_label = '30 min',
  text = 'Try a food you have never had',
  points = 30,
  hook = 'Adventure bite',
  minutes = 30,
  rules = 'Order or cook something new to you. Submit a photo with your dish.',
  sort_order = 4
where id = '00000000-0000-0000-0000-000000000004';

update public.challenges set
  time_label = '1 min',
  text = 'Tell a clean joke to two people',
  points = null,
  hook = 'Comedy hour',
  minutes = 1,
  rules = 'Share a family-friendly joke with at least two people. Bonus points if they laugh.',
  sort_order = 5
where id = '00000000-0000-0000-0000-000000000005';

-- Refresh catalog insert for fresh environments (idempotent).
insert into public.challenges (id, time_label, text, points, hook, minutes, rules, sort_order)
values
  ('00000000-0000-0000-0000-000000000001', '5 min', 'Give a genuine compliment', 15,
   'Spread good vibes', 5,
   'Compliment someone in person—a friend or a stranger. Submit a photo or short caption as proof.', 1),
  ('00000000-0000-0000-0000-000000000002', '15 min', 'Reach out to an old friend', 20,
   'Reconnect', 15,
   'Send a friendly text or voice note to someone you have not talked to in a while. Screenshot the message as proof.', 2),
  ('00000000-0000-0000-0000-000000000003', '20 min', 'Take a 20-minute walk', 25,
   'Get moving', 20,
   'Walk outside for at least 20 minutes. A photo of your route, step count, or a scenic shot counts as proof.', 3),
  ('00000000-0000-0000-0000-000000000004', '30 min', 'Try a food you have never had', 30,
   'Adventure bite', 30,
   'Order or cook something new to you. Submit a photo with your dish.', 4),
  ('00000000-0000-0000-0000-000000000005', '1 min', 'Tell a clean joke to two people', null,
   'Comedy hour', 1,
   'Share a family-friendly joke with at least two people. Bonus points if they laugh.', 5)
on conflict (id) do update set
  time_label = excluded.time_label,
  text = excluded.text,
  points = excluded.points,
  hook = excluded.hook,
  minutes = excluded.minutes,
  rules = excluded.rules,
  sort_order = excluded.sort_order;
