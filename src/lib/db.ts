import {createClient} from '@supabase/supabase-js';
export const db=createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!,process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!);
export type Incident={id:string;category:number;longitude:number;latitude:number;description:string;created_at:string;expires_at:string;last_confirmation_at:string|null;status:string;road_segment:string|null};
export const incidentFields='id,category,longitude,latitude,description,created_at,expires_at,last_confirmation_at,status,road_segment';
