import { createClient } from '@supabase/supabase-js';

// Ganti dengan URL dan Anon Key proyek Supabase Anda
const supabaseUrl = 'https://yltxsucpzthnzchziakc.supabase.co';
const supabaseAnonKey = 'YOUR_ANON_KEY'; // Ganti dengan Anon Key Anda

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
