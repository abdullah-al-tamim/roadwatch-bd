import type { Metadata } from 'next';
import './globals.css';
export const metadata: Metadata = { title: 'RoadWatch BD', description: 'Your Roads. Your Community. Your Safety.' };
export default function RootLayout({children}: {children: React.ReactNode}) {return <html lang="en"><body>{children}</body></html>}
