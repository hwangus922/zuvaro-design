import { useState, useEffect, useLayoutEffect, useRef, useId } from 'react';
import { motion, useMotionValue, useSpring, useTransform, useMotionTemplate, useVelocity, useAnimationFrame } from 'motion/react';
import { 
  Compass, 
  Smartphone, 
  Award,
  TrendingUp
} from 'lucide-react';

const Z = {
  text: '#0A0A0F',
  display: "'Sora', 'Inter', system-ui, sans-serif",
};

interface ZMarkProps {
  size?: number;
  gradient?: boolean;
  color?: string;
  stroke?: number;
}

function ZMark({ size = 64, gradient = false, color = Z.text, stroke = 7 }: ZMarkProps) {
  const uid = useId();
  const gid = `zg${uid}`, mid = `zm${uid}`;
  const pillX = 12, pillY = 38, pillW = 76, pillH = 24, pillR = 12;
  const strokeProps = {
    stroke: gradient ? `url(#${gid})` : color,
    strokeWidth: stroke, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const, fill: 'none',
  };
  return (
    <svg width={size} height={size} viewBox="0 0 100 100" fill="none" aria-label="Zuvaro">
      <defs>
        <linearGradient id={gid} x1="0" y1="100%" x2="100%" y2="0">
          <stop offset="0%" stopColor={color}/>
          <stop offset="55%" stopColor={color}/>
          <stop offset="100%" stopColor={color}/>
        </linearGradient>
        <mask id={mid} maskUnits="userSpaceOnUse">
          <rect width="100" height="100" fill="white"/>
          <circle cx="62" cy="38" r={stroke * 1.4} fill="black"/>
        </mask>
      </defs>
      <g mask={`url(#${mid})`}>
        <rect x={pillX} y={pillY} width={pillW} height={pillH} rx={pillR}
              transform="rotate(-45 50 50)" {...strokeProps}/>
      </g>
      <g>
        <rect x={pillX} y={pillY} width={pillW} height={pillH} rx={pillR}
              transform="rotate(45 50 50)" {...strokeProps}/>
        <path d="M76 14 L86 14 L86 24" {...strokeProps}/>
      </g>
    </svg>
  );
}

interface PhoneMockup2DProps {
  imageUrl: string;
}

function PhoneMockup2D({ imageUrl }: PhoneMockup2DProps) {
  return (
    <div className="relative z-10 w-full max-w-[240px] aspect-[9/19.5] rounded-[2.3rem] bg-[#0A0A0E] p-[4px] select-none border-[4px] border-zinc-900 shadow-none">
      {/* The Screen */}
      <div className="relative w-full h-full rounded-[1.95rem] bg-zinc-950 overflow-hidden isolate border border-zinc-850/45">
          <img 
            src={imageUrl} 
            alt="App UI Screenshot" 
            className="w-full h-full object-cover select-none"
            loading="lazy" decoding="async"
            onError={(e) => {
              e.currentTarget.src = 'https://images.unsplash.com/photo-1616423640778-28d1b53229bd?auto=format&fit=crop&w=400&q=80';
            }}
          />
      </div>
      {/* Speaker Bar Notch */}
      <div className="absolute top-[14px] left-1/2 -translate-x-1/2 w-12 h-2.5 bg-black rounded-full" />
    </div>
  );
}

export default function App() {
  const rootRef = useRef<HTMLDivElement>(null);

  const [logoFontSize, setLogoFontSize] = useState<string>('calc((100vw - 40px) / 3.65)');

  const [isMobile] = useState(() =>
    typeof window !== 'undefined' && window.matchMedia?.('(pointer: coarse)').matches
  );

  const phoneRef = useRef<HTMLDivElement>(null);
  const [phoneScale, setPhoneScale] = useState(1);

  useLayoutEffect(() => {
    if (phoneRef.current) {
      setPhoneScale(phoneRef.current.offsetWidth / 320);
    }
  }, []);

  useEffect(() => {
    const el = phoneRef.current;
    if (!el) return;
    const ro = new ResizeObserver((entries) => {
      setPhoneScale(entries[0].contentRect.width / 320);
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  // Responsive hero logo text font size to fit exactly 20px from sides
  useEffect(() => {
    const handleResize = () => {
      // document.documentElement.clientWidth avoids scrollbar width issues that cause text to be cut off
      const containerWidth = document.documentElement.clientWidth - 40;
      // 4.35 provides a safe fit for ZUVARO in Sora font at -0.05em tracking without wrapping or cutting off.
      const idealFontSize = Math.max(containerWidth / 4.35, 12);
      setLogoFontSize(`${idealFontSize}px`);
    };
    handleResize();
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Global Mouse Tracking for Blob and 3D Phone
  const mouseX = useMotionValue(typeof window !== 'undefined' ? window.innerWidth / 2 : 0);
  const mouseY = useMotionValue(typeof window !== 'undefined' ? window.innerHeight / 2 : 0);
  
  // Smooth lead point — tighter, more responsive
  const smoothMouseX = useSpring(mouseX, { stiffness: 140, damping: 22, mass: 1 });
  const smoothMouseY = useSpring(mouseY, { stiffness: 140, damping: 22, mass: 1 });

  // First trailing lag point — looser, more directional smear
  const trailMouseX = useSpring(mouseX, { stiffness: 45, damping: 12, mass: 1.8 });
  const trailMouseY = useSpring(mouseY, { stiffness: 45, damping: 12, mass: 1.8 });

  // Second deeper trailing lag point — heavy drag for pronounced direction trail
  const trail2MouseX = useSpring(mouseX, { stiffness: 22, damping: 8, mass: 2.2 });
  const trail2MouseY = useSpring(mouseY, { stiffness: 22, damping: 8, mass: 2.2 });

  // Time-varying position targets for the bottom hero background gradient
  const heroG1X = useMotionValue('50%');
  const heroG1Y = useMotionValue('100%');
  const heroG2X = useMotionValue('20%');
  const heroG2Y = useMotionValue('100%');
  const heroG3X = useMotionValue('80%');
  const heroG3Y = useMotionValue('100%');

  useAnimationFrame((time) => {
    // Smoother scaling factor for slower, more natural lava-lamp-like flow transitions
    const t = time / 1800;

    // Hero Gradient 1 (shifty center pink)
    const h1x = 50 + Math.sin(t * 0.7) * 14;
    const h1y = 95 + Math.cos(t * 0.9) * 10;
    heroG1X.set(`${h1x}%`);
    heroG1Y.set(`${h1y}%`);

    // Hero Gradient 2 (shifty left orange)
    const h2x = 20 + Math.cos(t * 0.8 + 1.2) * 18;
    const h2y = 90 + Math.sin(t * 1.2 + 0.5) * 15;
    heroG2X.set(`${h2x}%`);
    heroG2Y.set(`${h2y}%`);

    // Hero Gradient 3 (shifty right magenta)
    const h3x = 80 + Math.sin(t * 0.9 + 2.4) * 18;
    const h3y = 95 + Math.cos(t * 1.0 + 1.7) * 12;
    heroG3X.set(`${h3x}%`);
    heroG3Y.set(`${h3y}%`);
  });

  const vx = useVelocity(smoothMouseX);
  const vy = useVelocity(smoothMouseY);
  
  // Create raw dynamic stretching targets based on velocity changes
  const rawStretchX = useTransform(vx, v => Math.min(Math.max(200 + Math.abs(v) * 0.4, 200), 650));
  const rawStretchY = useTransform(vy, v => Math.min(Math.max(160 + Math.abs(v) * 0.3, 160), 520));

  // Run the size transformations through custom spring mechanics to prevent rapid, jerky size changes
  const stretchX = useSpring(rawStretchX, { stiffness: 35, damping: 16, mass: 1.6 });
  const stretchY = useSpring(rawStretchY, { stiffness: 35, damping: 16, mass: 1.6 });

  // Different stretch per axis so each layer has a distinct, irregular shape
  const stretchXMid = useTransform(stretchX, x => x * 2.4);
  const stretchYMid = useTransform(stretchY, y => y * 1.8);
  const stretchXTrail = useTransform(stretchX, x => x * 1.4);
  const stretchYTrail = useTransform(stretchY, y => y * 1.9);

  useEffect(() => {
    if (isMobile) return;
    const handleMouseMove = (e: MouseEvent) => {
      mouseX.set(e.clientX);
      mouseY.set(e.clientY);
    };
    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, [mouseX, mouseY, isMobile]);

  // Phone tilt values
  const rotateX = useTransform(smoothMouseY, (y) => {
    if (isMobile) return -8;
    if (typeof window === 'undefined') return 0;
    const center = window.innerHeight / 2;
    return -((y - center) / center) * 36;
  });
  
  const rotateY = useTransform(smoothMouseX, (x) => {
    if (isMobile) return 12;
    if (typeof window === 'undefined') return 0;
    const center = window.innerWidth / 2;
    return ((x - center) / center) * 36;
  });

  // Blob position updater: runs every frame, updates per-element CSS variables in viewport coordinates
  const lastBlobPos = useRef({ lx: -1, ly: -1, mx: -1, my: -1, tx: -1, ty: -1 });
  const lastStretch = useRef({ rx: 0, ry: 0, rxm: 0, rym: 0, rxt: 0, ryt: 0 });
  const blobElsRef = useRef<HTMLElement[]>([]);

  useEffect(() => {
    if (!isMobile) {
      blobElsRef.current = Array.from(document.querySelectorAll<HTMLElement>('.blob-window, .blob-text'));
    }
  }, [isMobile]);

  useAnimationFrame(() => {
    if (isMobile) return;
    const sx = smoothMouseX.get(), sy = smoothMouseY.get();
    const mx = trailMouseX.get(), my = trailMouseY.get();
    const t2x = trail2MouseX.get(), t2y = trail2MouseY.get();
    const rx = stretchX.get(), ry = stretchY.get();
    const rxm = stretchXMid.get(), rym = stretchYMid.get();
    const rxt = stretchXTrail.get(), ryt = stretchYTrail.get();

    const lp = lastBlobPos.current;
    const ls = lastStretch.current;
    const posChanged = sx !== lp.lx || sy !== lp.ly || mx !== lp.mx || my !== lp.my || t2x !== lp.tx || t2y !== lp.ty;
    const stretchChanged = rx !== ls.rx || ry !== ls.ry || rxm !== ls.rxm || rym !== ls.rym || rxt !== ls.rxt || ryt !== ls.ryt;

    if (posChanged) {
      lp.lx = sx; lp.ly = sy; lp.mx = mx; lp.my = my; lp.tx = t2x; lp.ty = t2y;
      const els = blobElsRef.current;
      for (let i = 0; i < els.length; i++) {
        const el = els[i];
        const r = el.getBoundingClientRect();
        el.style.setProperty('--blob-lx', `${sx - r.left}px`);
        el.style.setProperty('--blob-ly', `${sy - r.top}px`);
        el.style.setProperty('--blob-mx', `${mx - r.left}px`);
        el.style.setProperty('--blob-my', `${my - r.top}px`);
        el.style.setProperty('--blob-tx', `${t2x - r.left}px`);
        el.style.setProperty('--blob-ty', `${t2y - r.top}px`);
      }
    }

    if (stretchChanged && rootRef.current) {
      ls.rx = rx; ls.ry = ry; ls.rxm = rxm; ls.rym = rym; ls.rxt = rxt; ls.ryt = ryt;
      rootRef.current.style.setProperty('--blob-rx', `${rx}px`);
      rootRef.current.style.setProperty('--blob-ry', `${ry}px`);
      rootRef.current.style.setProperty('--blob-rx-mid', `${rxm}px`);
      rootRef.current.style.setProperty('--blob-ry-mid', `${rym}px`);
      rootRef.current.style.setProperty('--blob-rx-trail', `${rxt}px`);
      rootRef.current.style.setProperty('--blob-ry-trail', `${ryt}px`);
    }
  });

  return (
    <div 
      ref={rootRef}
      className="relative w-full min-h-screen bg-white text-zuvaro-text font-inter selection:bg-zuvaro-pink selection:text-white"
    >

      {/* HERO SECTION - 3D PHONE AND BLOB LOGO */}
      <section className="relative w-full min-h-[100svh] bg-white overflow-hidden flex flex-col items-center justify-center">

        {/* Full-hero grain overlay */}
        <div 
          className="absolute inset-0 pointer-events-none z-20"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noiseFilter'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='4.0' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noiseFilter)' opacity='0.09'/%3E%3C/svg%3E")`,
            backgroundRepeat: 'repeat',
            backgroundSize: '256px 256px',
          }}
        />

        {/* Abstract colorful gradient at the bottom edge that blends seamlessly into the white background */}
        <motion.div 
          className="absolute bottom-0 left-0 right-0 h-80 sm:h-[50vh] pointer-events-none z-10"
          style={{
            backgroundImage: useMotionTemplate`
              radial-gradient(ellipse 100% 100% at ${heroG1X} ${heroG1Y}, rgba(255, 255, 255, 1) 15%, rgba(255, 45, 149, 0.95) 50%, transparent 80%),
              radial-gradient(ellipse 80% 80% at ${heroG2X} ${heroG2Y}, rgba(255, 255, 255, 1) 20%, rgba(255, 106, 44, 0.95) 65%, transparent 90%),
              radial-gradient(ellipse 80% 80% at ${heroG3X} ${heroG3Y}, rgba(255, 255, 255, 1) 20%, rgba(192, 22, 134, 0.9) 60%, transparent 90%),
              linear-gradient(to top, rgba(255, 255, 255, 1) 0%, rgba(255, 255, 255, 0) 10%)
            `,
            backgroundBlendMode: 'normal, normal, normal, normal',
          }}
        />
        
        {/* LOGO WITH BLOB TRAIL EFFECT */}
        <div className="absolute top-[20px] left-[20px] right-[20px] z-0 pointer-events-none flex justify-center items-start overflow-hidden">
          <motion.div 
            className="w-full"
            style={{ fontSize: logoFontSize, display: 'grid', gridTemplateColumns: '1fr' }}
            initial={{ paddingTop: 50, opacity: 0 }}
            animate={{ paddingTop: 0, opacity: 1 }}
            transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
            transformTemplate={() => 'none'}
          >
            {/* Solid black text layer */}
            <h1 className="col-start-1 row-start-1 w-full text-center font-sora font-extrabold tracking-[-0.05em] uppercase leading-[0.8] select-none whitespace-nowrap text-black"
              aria-hidden="true"
            >
              ZUVARO
            </h1>
            {/* Blob overlay layer on top (same grid cell) */}
            <h1 className={`col-start-1 row-start-1 w-full text-center font-sora font-extrabold tracking-[-0.05em] uppercase leading-[0.8] select-none whitespace-nowrap ${isMobile ? 'mobile-gradient-text' : 'blob-text'}`}
              aria-hidden="true"
            >
              ZUVARO
            </h1>
            <span className="sr-only">ZUVARO</span>
          </motion.div>
        </div>

        {/* 3D PHONE WRAPPER */}
        <div style={{ perspective: 1200 }} className="relative z-10 w-full flex flex-col items-center justify-center mt-4 md:mt-0 gap-6">
          <motion.div
            ref={phoneRef}
            style={{ rotateX, rotateY, transformStyle: "preserve-3d", borderRadius: `${phoneScale * 3}rem` }}
            className="relative w-[65%] md:w-[75%] max-w-[340px] aspect-[9/19] bg-black shadow-2xl shadow-zinc-300/50 pointer-events-auto"
          >
            {/* Solid body layers creating continuous 3D depth */}
            <div 
              className="absolute bg-[#27272b]"
              style={{ borderRadius: `${phoneScale * 3}rem`, transform: `translateZ(${-6 * phoneScale}px)`, top: `${-2 * phoneScale}px`, bottom: `${-2 * phoneScale}px`, left: `${-2 * phoneScale}px`, right: `${-2 * phoneScale}px` }}
            />
            <div 
              className="absolute bg-[#1c1c1f]"
              style={{ borderRadius: `${phoneScale * 3}rem`, transform: `translateZ(${-14 * phoneScale}px)`, top: `${-4 * phoneScale}px`, bottom: `${-4 * phoneScale}px`, left: `${-4 * phoneScale}px`, right: `${-4 * phoneScale}px` }}
            />
            <div 
              className="absolute bg-zinc-900"
              style={{ borderRadius: `${phoneScale * 3}rem`, transform: `translateZ(${-22 * phoneScale}px)`, top: `${-6 * phoneScale}px`, bottom: `${-6 * phoneScale}px`, left: `${-6 * phoneScale}px`, right: `${-6 * phoneScale}px` }}
            />
            <div 
              className="absolute bg-[#0a0a0c] shadow-[0_30px_60px_-15px_rgba(0,0,0,0.5)]"
              style={{ borderRadius: `${phoneScale * 3}rem`, transform: `translateZ(${-32 * phoneScale}px)`, top: `${-8 * phoneScale}px`, bottom: `${-8 * phoneScale}px`, left: `${-8 * phoneScale}px`, right: `${-8 * phoneScale}px` }}
            />

            {/* Front Face */}
            <div 
              className="absolute inset-0 bg-black border-zinc-900" 
              style={{ 
                borderRadius: `${phoneScale * 3}rem`,
                borderWidth: `${phoneScale * 8}px`,
                transform: "translateZ(0px)", 
                transformStyle: "preserve-3d" 
              }}
            >
              {/* The Screen */}
              <div className="absolute inset-0 bg-zinc-800 overflow-hidden isolate"
                style={{ borderRadius: `${phoneScale * 2.5}rem` }}
              >
                <img 
                  src="/Zuvaro-Website/MissionsUI.png" 
                  alt="Zuvaro home screen with daily dares" 
                  className="w-full h-full object-cover"
                  loading="lazy" decoding="async"
                  onError={(e) => {
                    e.currentTarget.src = 'https://images.unsplash.com/photo-1616423640778-28d1b53229bd?auto=format&fit=crop&w=400&q=80';
                  }}
                />
              </div>
              
              {/* Dynamic Screen Glare */}
              <div 
                className="absolute inset-0 pointer-events-none"
                style={{
                  borderRadius: `${phoneScale * 2.5}rem`,
                  background: 'linear-gradient(105deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0) 40%)',
                  mixBlendMode: 'overlay'
                }}
              />
              
              {/* Dynamic Specular lighting responding to tilt */}
              <motion.div 
                className="absolute inset-0 pointer-events-none opacity-40 bg-gradient-radial from-white/20 to-transparent"
                style={{
                  borderRadius: `${phoneScale * 2.2}rem`,
                  x: useTransform(rotateY, [-15, 15], ['-30%', '30%']),
                  y: useTransform(rotateX, [-15, 15], ['-30%', '30%']),
                }}
              />

              {/* Dynamic Shadow responding to tilt */}
              <motion.div
                 className="absolute -z-10 bg-black/10 blur-2xl transition-opacity animate-pulse"
                 style={{
                   borderRadius: `${phoneScale * 3.5}rem`,
                   top: `${-8 * phoneScale}px`,
                   bottom: `${-8 * phoneScale}px`,
                   left: `${-8 * phoneScale}px`,
                   right: `${-8 * phoneScale}px`,
                   x: useTransform(rotateY, [-15, 15], ['10%', '-10%']),
                   y: useTransform(rotateX, [-15, 15], ['10%', '-10%']),
                 }}
              />
            </div>
            
            {/* Side Buttons (positioned between front and back roughly) */}
            <div className="absolute top-[25%] -left-[2px] md:-left-[4px] w-1.5 h-12 bg-zinc-800 rounded-l-sm" style={{ transform: `translateZ(${-6 * phoneScale}px)` }} />
            <div className="absolute top-[35%] -left-[2px] md:-left-[4px] w-1.5 h-12 bg-zinc-800 rounded-l-sm" style={{ transform: `translateZ(${-6 * phoneScale}px)` }} />
            <div className="absolute top-[30%] -right-[2px] md:-right-[4px] w-1.5 h-16 bg-zinc-800 rounded-r-sm" style={{ transform: `translateZ(${-6 * phoneScale}px)` }} />
            
          </motion.div>
        
        </div>

        {/* BOTTOM LEFT TEXT: LOGO BRAND MARK ONLY (ENLARGED) */}
        <div className="absolute bottom-[30px] left-[20px] md:bottom-[40px] md:left-[40px] z-20 flex items-center">
          <ZMark size={64} />
        </div>

        {/* BOTTOM RIGHT TEXT AND INSTALL BUTTON (MOVED & ENLARGED) */}
        <div className="absolute bottom-[30px] right-[20px] md:bottom-[40px] md:right-[40px] z-20 max-w-[280px] md:max-w-[420px] flex flex-col items-end gap-3 md:gap-4 text-right pointer-events-auto select-none">
          {/* INSTALL BUTTON IN HERO (ENLARGED) */}
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            transition={{ type: 'spring', stiffness: 400, damping: 20 }}
            className="px-9 py-4 rounded-full bg-[#0A0A0F] text-white border border-zinc-800/80 hover:border-transparent hover:bg-gradient-to-r hover:from-[#FF2D95] hover:to-[#FF6A2C] hover:shadow-lg hover:shadow-pink-500/25 active:scale-95 transition-all duration-300 text-xs md:text-sm font-bold uppercase tracking-widest flex items-center gap-2.5 cursor-pointer shadow-xl group"
          >
            <Smartphone className="w-5 h-5 text-pink-500 group-hover:text-white transition-colors duration-300" />
            Install App
          </motion.button>
          
          <p className="text-[#050508] font-black text-xl md:text-3xl tracking-tight leading-none mt-1">
            Daily dares. Real chaos.
          </p>
        </div>

      </section>

      {/* MAIN SYSTEM CONTAINER */}
      <main className="relative pt-8 pb-32 px-4 md:px-8 max-w-7xl mx-auto z-10">
        
        {/* THREE DISTINCT REVOLUTIONARY SHOWCASES */}
        <div className="space-y-32 md:space-y-48 mt-12 mb-20">

          {/* SECTION 1: MISSIONS */}
          <section className="grid lg:grid-cols-12 gap-12 items-center section-vis">
            
            {/* White Mockup Box - No Shadow */}
            <motion.div 
              initial={{ opacity: 0, y: 40, scale: 0.97 }}
              whileInView={{ opacity: 1, y: 0, scale: 1 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.9, ease: [0.16, 1, 0.3, 1] }}
              className={`lg:col-span-6 flex flex-col items-center justify-center p-8 md:p-12 rounded-3xl ${isMobile ? 'mobile-gradient-window' : 'blob-window'} border border-gray-200/90 relative overflow-hidden min-h-[460px] md:min-h-[520px] shadow-none group`}
            >
              
              {/* Overlay layout guidelines pattern */}
              <div 
                className="absolute inset-0 opacity-10 pointer-events-none select-none z-0"
                style={{
                  backgroundImage: `linear-gradient(rgba(0, 0, 0, 0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(0, 0, 0, 0.03) 1px, transparent 1px)`,
                  backgroundSize: '20px 20px'
                }}
              />

              {/* The Phone UI with Missions Image */}
              <motion.div whileHover={{ scale: 1.05 }} transition={{ type: 'spring', stiffness: 400, damping: 20 }} className="relative z-10 w-full flex justify-center">
                <PhoneMockup2D imageUrl="/Zuvaro-Website/MissionsUI.png" />
              </motion.div>

            </motion.div>

            {/* Missions Text Column */}
            <motion.div 
              className="lg:col-span-6 flex flex-col justify-center space-y-6 lg:pr-8 relative z-20"
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, margin: "-50px" }}
              variants={{
                visible: { transition: { staggerChildren: 0.12 } }
              }}
            >
              <motion.div 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F4F3F8] border border-gray-200 w-fit select-none"
              >
                <Compass className="w-3.5 h-3.5 text-zuvaro-pink" />
                <span className="text-[10px] font-bold tracking-widest text-[#FF2D95] uppercase">01 / Dare Feed</span>
              </motion.div>
              <motion.h3 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="font-sora font-extrabold text-3xl md:text-4xl tracking-tight text-neutral-900"
              >
                Pick Your Dare
              </motion.h3>
              <motion.p 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="text-zinc-650 text-base md:text-lg leading-relaxed font-normal"
              >
                Browse dares from your crew's group chat or the daily quest chain. Filter by recommended, rewarding, or short — harder dares earn more points, and some are just for the lulz. Accept one, start the timer, and see how much clout you're willing to lose.
              </motion.p>
            </motion.div>

          </section>

          {/* SECTION 2: LEADERBOARD */}
          <section className="grid lg:grid-cols-12 gap-12 items-center section-vis">
            
            {/* Leaderboard Text Column */}
            <motion.div 
              className="lg:col-span-6 flex flex-col justify-center space-y-6 lg:pl-8 order-2 lg:order-1 relative z-20"
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, margin: "-50px" }}
              variants={{
                visible: { transition: { staggerChildren: 0.12 } }
              }}
            >
              <motion.div 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F4F3F8] border border-gray-200 w-fit select-none"
              >
                <Award className="w-3.5 h-3.5 text-zuvaro-orange" />
                <span className="text-[10px] font-bold tracking-widest text-[#FF6A2C] uppercase">02 / Friends Board</span>
              </motion.div>
              <motion.h3 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="font-sora font-extrabold text-3xl md:text-4xl tracking-tight text-neutral-900"
              >
                Climb the Leaderboard
              </motion.h3>
              <motion.p 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="text-zinc-650 text-base md:text-lg leading-relaxed font-normal"
              >
                See who's actually doing the dares. Rank against friends, your club, or globally on a live points board. Watch your streak, track who passed you, and fight for the top spot — bragging rights only, dignity not included.
              </motion.p>
            </motion.div>

            {/* White Mockup Box - No Shadow */}
            <motion.div 
              initial={{ opacity: 0, y: 40, scale: 0.97 }}
              whileInView={{ opacity: 1, y: 0, scale: 1 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.9, ease: [0.16, 1, 0.3, 1], delay: 0.1 }}
              className={`lg:col-span-6 flex flex-col items-center justify-center p-8 md:p-12 rounded-3xl ${isMobile ? 'mobile-gradient-window' : 'blob-window'} border border-gray-200/90 relative overflow-hidden min-h-[460px] md:min-h-[520px] shadow-none group order-1 lg:order-2`}
            >
              
              {/* Overlay layout guidelines pattern */}
              <div 
                className="absolute inset-0 opacity-10 pointer-events-none select-none z-0"
                style={{
                  backgroundImage: `linear-gradient(rgba(0, 0, 0, 0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(0, 0, 0, 0.03) 1px, transparent 1px)`,
                  backgroundSize: '20px 20px'
                }}
              />

              {/* The Phone UI with Leaderboard Image */}
              <motion.div whileHover={{ scale: 1.05 }} transition={{ type: 'spring', stiffness: 400, damping: 20 }} className="relative z-10 w-full flex justify-center">
                <PhoneMockup2D imageUrl="/Zuvaro-Website/LeaderboardUI.png" />
              </motion.div>

            </motion.div>

          </section>

          {/* SECTION 3: PROOF PAGE */}
          <section className="grid lg:grid-cols-12 gap-12 items-center section-vis">
            
            {/* White Mockup Box - No Shadow */}
            <motion.div 
              initial={{ opacity: 0, y: 40, scale: 0.97 }}
              whileInView={{ opacity: 1, y: 0, scale: 1 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ duration: 0.9, ease: [0.16, 1, 0.3, 1] }}
              className={`lg:col-span-6 flex flex-col items-center justify-center p-8 md:p-12 rounded-3xl ${isMobile ? 'mobile-gradient-window' : 'blob-window'} border border-gray-200/90 relative overflow-hidden min-h-[460px] md:min-h-[520px] shadow-none group`}
            >
              
              {/* Overlay layout guidelines pattern */}
              <div 
                className="absolute inset-0 opacity-10 pointer-events-none select-none z-0"
                style={{
                  backgroundImage: `linear-gradient(rgba(0, 0, 0, 0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(0, 0, 0, 0.03) 1px, transparent 1px)`,
                  backgroundSize: '20px 20px'
                }}
              />

              {/* The Phone UI with Proof Image */}
              <motion.div whileHover={{ scale: 1.05 }} transition={{ type: 'spring', stiffness: 400, damping: 20 }} className="relative z-10 w-full flex justify-center">
                <PhoneMockup2D imageUrl="/Zuvaro-Website/ProofUI.png" />
              </motion.div>

            </motion.div>

            {/* Proof Text Column */}
            <motion.div 
              className="lg:col-span-6 flex flex-col justify-center space-y-6 lg:pr-8 relative z-20"
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true, margin: "-50px" }}
              variants={{
                visible: { transition: { staggerChildren: 0.12 } }
              }}
            >
              <motion.div 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#F4F3F8] border border-gray-200 w-fit select-none"
              >
                <TrendingUp className="w-3.5 h-3.5 text-zuvaro-magenta" />
                <span className="text-[10px] font-bold tracking-widest text-[#C01686] uppercase">03 / Photo Proof</span>
              </motion.div>
              <motion.h3 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="font-sora font-extrabold text-3xl md:text-4xl tracking-tight text-neutral-900"
              >
                Prove You Did It
              </motion.h3>
              <motion.p 
                variants={{
                  hidden: { opacity: 0, y: 20 },
                  visible: { opacity: 1, y: 0, transition: { duration: 0.7, ease: [0.16, 1, 0.3, 1] } }
                }}
                className="text-zinc-650 text-base md:text-lg leading-relaxed font-normal"
              >
                Finished the dare? Snap a photo, add an optional caption, and submit proof. Your submission goes to review — once approved, the points hit your total and your quest chain advances. Get rejected? Resubmit and try again.
              </motion.p>
            </motion.div>

          </section>

        </div>

      </main>

      {/* REVOLUTIONARY DARK FOOTER WITH GLOWING WHITE LOGO */}
      <footer className="relative bg-[#050508] border-t border-zinc-900 px-[20px] select-none overflow-hidden text-center flex flex-col items-center pt-[20px] pb-8">
        
        {/* BIG LOGO WITH EXCLUSIVE WHITE BLOB EFFECT - Absolute positioned matching hero */}
        <div className="w-full flex justify-center items-start overflow-hidden pointer-events-none select-none z-10 mb-[60px] md:mb-[100px]">
          <motion.div 
            className="w-full"
            style={{ fontSize: logoFontSize, display: 'grid', gridTemplateColumns: '1fr' }}
            initial={{ paddingTop: 50, opacity: 0 }}
            whileInView={{ paddingTop: 0, opacity: 1 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
            transformTemplate={() => 'none'}
          >
            {/* Solid white text layer */}
            <h2 className="col-start-1 row-start-1 w-full text-center font-sora font-extrabold tracking-[-0.05em] uppercase leading-[0.8] whitespace-nowrap text-white"
              aria-hidden="true"
            >
              ZUVARO
            </h2>
            {/* Blob overlay layer on top (same grid cell) */}
            <h2 className={`col-start-1 row-start-1 w-full text-center font-sora font-extrabold tracking-[-0.05em] uppercase leading-[0.8] whitespace-nowrap ${isMobile ? 'mobile-gradient-text' : 'blob-text'}`}
              aria-hidden="true"
            >
              ZUVARO
            </h2>
            <span className="sr-only">ZUVARO</span>
          </motion.div>
        </div>

        {/* INSTALL BUTTON IN FOOTER */}
        <div className="z-10 pointer-events-auto">
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            transition={{ type: 'spring', stiffness: 400, damping: 20 }}
            className="px-9 py-4 rounded-full bg-[#0A0A0F] text-white border border-zinc-800/80 hover:border-transparent hover:bg-gradient-to-r hover:from-[#FF2D95] hover:to-[#FF6A2C] hover:shadow-lg hover:shadow-pink-500/25 active:scale-95 transition-all duration-300 text-xs md:text-sm font-bold uppercase tracking-widest flex items-center gap-2.5 cursor-pointer shadow-xl group"
          >
            <Smartphone className="w-5 h-5 text-pink-500 group-hover:text-white transition-colors duration-300" />
            Install App
          </motion.button>
        </div>

        {/* Small Nyvø Credit */}
        <div className="z-10 max-w-7xl mx-auto w-full text-center mt-12">
          <p className="text-zinc-500 text-[11px] tracking-wide select-text">
            Website designed and developed by <a href="https://nyvo.is-a.dev" target="_blank" rel="noopener noreferrer" className="text-zinc-400 hover:text-white underline transition-colors font-medium">Nyvø</a>
          </p>
        </div>

      </footer>

    </div>
  );
}
