// lib/supabaseClient.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://yltxsucpzthnzchziakc.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsdHhzdWNwenRobnpjaHppYWtjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwOTQxNDAsImV4cCI6MjA3MDY3MDE0MH0.06652ebnPe0k6n9qVf4CI8x1OORUVaWnjjrLbCPcBq4'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)