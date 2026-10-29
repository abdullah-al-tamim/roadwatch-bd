'use client';
import {useEffect,useState} from 'react';
import {db,incidentFields,type Incident} from '@/lib/db';
export default function Community({longitude,latitude,category,description,onDone}:{longitude:number;latitude:number;category:number;description:string;onDone:()=>void}){
 const [user,setUser]=useState<string|null>(null),[email,setEmail]=useState(''),[notice,setNotice]=useState(''),[busy,setBusy]=useState(false);
 useEffect(()=>{db.auth.getUser().then(({data})=>setUser(data.user?.id??null));const {data}=db.auth.onAuthStateChange((_,s)=>setUser(s?.user.id??null));return()=>data.subscription.unsubscribe()},[]);
 async function submit(){setBusy(true);try{const {error}=await db.from('incidents').insert({category,author_id:user,longitude,latitude,description});if(error)throw error;setNotice('Report submitted; awaiting independent confirmation.');onDone()}catch(e){setNotice(e instanceof Error?e.message:JSON.stringify(e))}finally{setBusy(false)}}
 async function login(){setBusy(true);const {error}=await db.auth.signInWithOtp({email,options:{emailRedirectTo:window.location.origin}});setNotice(error?.message??'Check your email for a sign-in link.');setBusy(false)}
 return <section><p role="status">{notice}</p>{user?<button className="primary" disabled={busy} onClick={submit}>{busy?'Submitting…':'Submit report'}</button>:<><label>Email<input style={{width:'100%',padding:14,border:'1px solid #b8c7bf',borderRadius:12}} type="email" value={email} onChange={e=>setEmail(e.target.value)}/></label><button className="primary" disabled={busy||!email.includes('@')} onClick={login}>Email me a sign-in link</button></>}</section>
}
