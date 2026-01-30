# CP Repository - Complete Project Documentation

## Project Overview
This is a Competitive Programming (CP) problem tracker app. Users can log in, add problems from various platforms (LeetCode, Codeforces, CSES, etc.), track their status (Pending/Attempt/Solved), add custom tags, and view statistics.

## Database Connection
- **Supabase URL:** `https://daurmqazalgomkpnkamh.supabase.co`
- **Auth Method:** Email/Password authentication using Supabase Auth
- **Client:** `supabase_flutter` package

## Table Structure

### Table 1: `problems`
| Column | Type | Constraints | Default | Description |
|--------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique problem ID |
| `user_id` | UUID | NOT NULL | - | Foreign key to `auth.users.id` |
| `title` | TEXT | NOT NULL | - | Problem title |
| `problem_url` | TEXT | NOT NULL | - | Full URL to the problem |
| `platform` | TEXT | NOT NULL | `'LeetCode'` | Platform name |
| `status` | TEXT | - | `'Pending'` | Pending/Attempt/Solved |
| `tags` | TEXT[] | - | `'{}'` | Array of custom tags |
| `created_at` | TIMESTAMPTZ | - | `now()` UTC | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | - | `now()` UTC | Update timestamp |

### Table 2: `user_profiles`
| Column | Type | Constraints | Default | Description |
|--------|------|-------------|---------|-------------|
| `id` | UUID | PRIMARY KEY | `gen_random_uuid()` | Unique profile ID |
| `user_id` | UUID | NOT NULL UNIQUE | - | Foreign key to `auth.users.id` |
| `full_name` | TEXT | - | - | User's full name |
| `university` | TEXT | - | - | User's university |
| `created_at` | TIMESTAMPTZ | - | `now()` UTC | Creation timestamp |
| `updated_at` | TIMESTAMPTZ | - | `now()` UTC | Update timestamp |

## Row Level Security (RLS) Policies

### For `problems` table:
1. `Users can view own problems` - SELECT where `auth.uid() = user_id`
2. `Users can insert own problems` - INSERT with `auth.uid() = user_id`
3. `Users can update own problems` - UPDATE where `auth.uid() = user_id`
4. `Users can delete own problems` - DELETE where `auth.uid() = user_id`

### For `user_profiles` table:
1. `Users can view own profile` - SELECT where `auth.uid() = user_id`
2. `Users can update own profile` - UPDATE where `auth.uid() = user_id`
3. `Users can insert own profile` - INSERT with `auth.uid() = user_id`

## Database Functions & Triggers
1. **`handle_new_user()` function** - Auto-creates user profile on registration
2. **`on_auth_user_created` trigger** - Calls `handle_new_user()` after user signup
3. **Function Security:** Fixed with `SECURITY DEFINER SET search_path = public`

## Current Data State
- **Tables:** Both `problems` and `user_profiles` tables exist
- **Structure:** Schema matches Flutter app exactly
- **Status:** All RLS policies configured and working
- **Triggers:** User profile auto-creation enabled

## Flutter ↔ Supabase Mapping

### `problems` table mapping:
| Database Column | Dart Model Field | Type |
|-----------------|------------------|------|
| `id` | `Problem.id` | `String` |
| `user_id` | `Problem.userId` | `String` |
| `title` | `Problem.title` | `String` |
| `problem_url` | `Problem.url` | `String` |
| `platform` | `Problem.platform` | `String` |
| `status` | `Problem.status` | `String` |
| `tags` | `Problem.tags` | `List<String>` |
| `created_at` | `Problem.createdAt` | `DateTime` |

### `user_profiles` table mapping:
| Database Column | Dart Function | Type |
|-----------------|---------------|------|
| `full_name` | `updateUserProfile(fullName: ...)` | `String?` |
| `university` | `updateUserProfile(university: ...)` | `String?` |
| `user_id` | Automatically set via `auth.uid()` | `String` |

## Available Database Functions (Flutter)
1. `getProblems()` - Get all problems for current user
2. `addProblem(Problem problem)` - Add new problem
3. `updateProblemStatus()` - Change problem status
4. `updateProblemTags()` - Update tags for a problem
5. `deleteProblem()` - Delete a problem
6. `getStats()` - Get problem statistics
7. `getUserProfile()` - Get user profile data
8. `updateUserProfile()` - Update user profile

## Authentication Flow
1. User registers/logs in via `supabase.auth`
2. **Auto-trigger:** `on_auth_user_created` creates user profile automatically
3. User ID is automatically available via `supabase.auth.currentUser?.id`
4. All table operations automatically use this user ID via RLS
5. Profile automatically created/updated when user edits profile

## Current Features
1. **Problem Management:** Add, edit, delete problems with status tracking
2. **Custom Tags:** Add any tags (free text input)
3. **Tag Filtering:** Filter problems by tags in home screen
4. **User Profiles:** Store user name and university (auto-created on registration)
5. **Statistics:** Track solved/attempt/pending counts
6. **Platform Support:** Works with any CP platform (LeetCode, Codeforces, CSES, etc.)
7. **Pinning System:** Pin important problems for focus
8. **Responsive Design:** Works on mobile, tablet, and desktop

## App File Structure (15 files)
1. `main.dart` - App initialization
2. `database.dart` - All Supabase functions
3. `models/problem.dart` - Problem data model
4. `screens/splash_screen.dart` - Launch screen
5. `screens/login_screen.dart` - Login screen
6. `screens/register_screen.dart` - Registration screen
7. `screens/forgot_password_screen.dart` - Password reset
8. `screens/home_screen.dart` - Main problem list
9. `screens/add_problem_screen.dart` - Add new problem
10. `screens/welcome_screen.dart` - App introduction
11. `screens/profile_edit_screen.dart` - Edit profile
12. `screens/settings_screen.dart` - App settings
13. `widgets/simple_button.dart` - Reusable button
14. `widgets/message_widget.dart` - Error/success message widget
15. `widgets/problem_card.dart` - Unified problem display widget

---