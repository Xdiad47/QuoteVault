# QuoteVault 📖✨

A beautiful quote discovery and collection app built with Flutter, featuring cloud sync, customizable themes, and shareable quote cards.

![Flutter](https://img.shields.io/badge/Flutter-3.10.4-blue)
![Supabase](https://img.shields.io/badge/Supabase-Backend-green)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-orange)

## 📱 Features

### Core Functionality
- 🔐 **User Authentication** - Sign up, login, password reset with Supabase Auth
- 📚 **Quote Browsing** - Browse 100+ curated quotes across 5 categories
- 🔍 **Smart Search** - Search quotes by keyword or author
- ❤️ **Favorites** - Save favorite quotes with cloud sync across devices
- 🌅 **Quote of the Day** - Daily inspirational quote on home screen
- 🎨 **Share as Image** - Generate beautiful quote cards with 3 different templates
- 📤 **Easy Sharing** - Share quotes as text or images via system share sheet

### User Experience
- 🌙 **Dark Mode** - System-based dark/light theme support
- 🎯 **Category Filters** - Browse by Motivation, Love, Success, Wisdom, Humor
- 🔄 **Pull to Refresh** - Refresh quote feed with a simple swipe
- 💾 **Session Persistence** - Stay logged in across app restarts
- 🏗️ **Clean Architecture** - MVVM pattern for maintainable code

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter |
| Language | Dart |
| Architecture | MVVM (Model-View-ViewModel) |
| State Management | Provider |
| Backend | Supabase (Auth + Database) |
| Database | PostgreSQL (via Supabase) |
| Image Generation | Flutter RepaintBoundary |
| Sharing | share_plus package |

## 📋 Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** (3.10.4 or higher) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Supabase Account** (free tier) - [Sign up here](https://supabase.com)
- **Git** for version control

## 🚀 Installation & Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/quote-vault.git
cd quote-vault
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Supabase Credentials

⚠️ **IMPORTANT**: The Supabase configuration file is NOT included in this repository for security reasons.

#### Create the Configuration File

1. **Navigate to the config directory:**
   ```bash
   mkdir -p lib/config
   ```

2. **Create a new file** `lib/config/supabase_config.dart` with the following content:

   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
   }
   ```

3. **Get Your Supabase Credentials:**

   a. Go to [Supabase Dashboard](https://supabase.com/dashboard)

   b. Create a new project or select an existing one

   c. Navigate to: **Project Settings** → **API**

   d. Copy the following values:
      - **Project URL** (e.g., `https://xxxxx.supabase.co`)
      - **anon public** key (under "Project API keys")

4. **Update the config file** with your actual credentials:

   ```dart
   class SupabaseConfig {
     static const String supabaseUrl = 'https://yourproject.supabase.co';
     static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
   }
   ```

5. **Verify the file is gitignored:**

   Check that `.gitignore` contains:
   ```
   lib/config/supabase_config.dart
   ```

### Step 4: Setup Supabase Database

#### a) Create Database Tables

Go to **SQL Editor** in your Supabase Dashboard and run this SQL:

```sql
-- Create quotes table
CREATE TABLE quotes (
  id BIGSERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  author VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user favorites table
CREATE TABLE user_favorites (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  quote_id BIGINT REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, quote_id)
);

-- Create collections table (optional, for future features)
CREATE TABLE collections (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create collection items table (optional, for future features)
CREATE TABLE collection_items (
  id BIGSERIAL PRIMARY KEY,
  collection_id BIGINT REFERENCES collections(id) ON DELETE CASCADE,
  quote_id BIGINT REFERENCES quotes(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(collection_id, quote_id)
);

-- Enable Row Level Security
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_items ENABLE ROW LEVEL SECURITY;

-- Policies for quotes (public read)
CREATE POLICY "Anyone can read quotes" 
ON quotes FOR SELECT 
USING (true);

-- Policies for user_favorites
CREATE POLICY "Users can view own favorites" 
ON user_favorites FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites" 
ON user_favorites FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites" 
ON user_favorites FOR DELETE 
USING (auth.uid() = user_id);

-- Policies for collections
CREATE POLICY "Users can view own collections" 
ON collections FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own collections" 
ON collections FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own collections" 
ON collections FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own collections" 
ON collections FOR DELETE 
USING (auth.uid() = user_id);

-- Policies for collection_items
CREATE POLICY "Users can view own collection items" 
ON collection_items FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM collections 
    WHERE collections.id = collection_items.collection_id 
    AND collections.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own collection items" 
ON collection_items FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM collections 
    WHERE collections.id = collection_items.collection_id 
    AND collections.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete own collection items" 
ON collection_items FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM collections 
    WHERE collections.id = collection_items.collection_id 
    AND collections.user_id = auth.uid()
  )
);
```

#### b) Seed Sample Quotes

Insert at least 20-100 quotes across 5 categories. Example:

```sql
INSERT INTO quotes (text, author, category) VALUES
-- Motivation
('The only way to do great work is to love what you do.', 'Steve Jobs', 'Motivation'),
('Believe you can and you''re halfway there.', 'Theodore Roosevelt', 'Motivation'),
('Success is not final, failure is not fatal: it is the courage to continue that counts.', 'Winston Churchill', 'Motivation'),
('Don''t watch the clock; do what it does. Keep going.', 'Sam Levenson', 'Motivation'),
('The future belongs to those who believe in the beauty of their dreams.', 'Eleanor Roosevelt', 'Motivation'),

-- Love
('Love is composed of a single soul inhabiting two bodies.', 'Aristotle', 'Love'),
('The best thing to hold onto in life is each other.', 'Audrey Hepburn', 'Love'),
('Love all, trust a few, do wrong to none.', 'William Shakespeare', 'Love'),
('Where there is love there is life.', 'Mahatma Gandhi', 'Love'),
('You know you''re in love when you can''t fall asleep because reality is finally better than your dreams.', 'Dr. Seuss', 'Love'),

-- Success
('Success is not the key to happiness. Happiness is the key to success.', 'Albert Schweitzer', 'Success'),
('Don''t be afraid to give up the good to go for the great.', 'John D. Rockefeller', 'Success'),
('I find that the harder I work, the more luck I seem to have.', 'Thomas Jefferson', 'Success'),
('Success usually comes to those who are too busy to be looking for it.', 'Henry David Thoreau', 'Success'),
('The way to get started is to quit talking and begin doing.', 'Walt Disney', 'Success'),

-- Wisdom
('The only true wisdom is in knowing you know nothing.', 'Socrates', 'Wisdom'),
('It is better to remain silent at the risk of being thought a fool, than to talk and remove all doubt of it.', 'Maurice Switzer', 'Wisdom'),
('The fool doth think he is wise, but the wise man knows himself to be a fool.', 'William Shakespeare', 'Wisdom'),
('Turn your wounds into wisdom.', 'Oprah Winfrey', 'Wisdom'),
('The journey of a thousand miles begins with one step.', 'Lao Tzu', 'Wisdom'),

-- Humor
('I''m not superstitious, but I am a little stitious.', 'Michael Scott', 'Humor'),
('I used to think I was indecisive, but now I''m not so sure.', 'Unknown', 'Humor'),
('I''m on a seafood diet. I see food and I eat it.', 'Unknown', 'Humor'),
('The road to success is dotted with many tempting parking spaces.', 'Will Rogers', 'Humor'),
('Age is of no importance unless you''re a cheese.', 'Billie Burke', 'Humor');

-- Add more quotes as needed to reach 100+ total
```

**💡 TIP**: Use AI tools (ChatGPT, Claude) to generate 100 quotes quickly:
```
Prompt: "Generate 100 quotes with author and category (Motivation, Love, Success, Wisdom, Humor) in SQL INSERT format"
```

#### c) Configure Email Authentication (Optional)

For easier testing, you can disable email confirmation:

1. Go to **Authentication** → **Providers** → **Email**
2. Toggle **OFF** "Confirm email"
3. Click **Save**

### Step 5: Run the App

```bash
# Check for Flutter issues
flutter doctor

# Run on your device/emulator
flutter run
```

Choose your target device (Android emulator, iOS simulator, or physical device).

## 📁 Project Structure

```
quote_vault/
├── lib/
│   ├── config/
│   │   ├── supabase_config.dart.example  # Template (in GitHub)
│   │   └── supabase_config.dart          # Your credentials (NOT in GitHub)
│   ├── models/
│   │   ├── quote_model.dart
│   │   ├── user_model.dart
│   │   └── collection_model.dart
│   ├── viewmodels/
│   │   ├── auth_viewmodel.dart
│   │   ├── quote_viewmodel.dart
│   │   └── favorites_viewmodel.dart
│   ├── views/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   ├── services/
│   │   ├── supabase_service.dart
│   │   └── share_service.dart
│   ├── widgets/
│   │   ├── quote_card.dart
│   │   ├── quote_card_templates.dart
│   │   └── share_options_sheet.dart
│   └── main.dart
├── android/
├── ios/
├── .gitignore
├── pubspec.yaml
└── README.md
```

## 🎯 How It Works

### MVVM Architecture

**Model** → **ViewModel** → **View**

- **Models**: Data classes (`Quote`, `UserModel`)
- **ViewModels**: Business logic using `ChangeNotifier` (Provider)
- **Views**: UI that listens to ViewModels using `Consumer`

Example Flow:
```
User taps "Favorite" → QuoteViewModel.toggleFavorite() → Supabase API call → 
notifyListeners() → UI rebuilds → Heart icon fills
```

### Authentication Flow

```
App Start → AuthWrapper checks session → 
  ├─ Logged in? → Home Screen
  └─ Not logged in? → Login Screen

Login Success → Session saved → Auto-redirect on app restart
```

### Data Synchronization

- User favorites sync in real-time with Supabase
- Quotes are fetched from PostgreSQL database
- Session persists using Supabase `persistSession`

## 🤖 AI Tools Used

This project leveraged AI-assisted development for faster iteration:

| Tool | Purpose | Usage |
|------|---------|-------|
| **ChatGPT** | Architecture design, code generation | 70% of initial code |
| **GitHub Copilot** | Code completion, boilerplate | 20% productivity boost |
| **Claude AI** | Debugging, refactoring | Problem-solving |

### Example AI Workflow:
1. **Prompt**: "Create Flutter login screen with email validation using Provider"
2. **AI Output**: Complete widget code with form validation
3. **Developer**: Customize UI, integrate with backend
4. **Test & Iterate**

## 🐛 Troubleshooting

### Issue: "Email not confirmed" error

**Solution**: Disable email confirmation in Supabase
1. Go to **Authentication** → **Providers** → **Email**
2. Toggle **OFF** "Confirm email"
3. Save changes

### Issue: Build error - "supabase_config.dart not found"

**Solution**: You forgot to create the config file!
```bash
# Create the file
touch lib/config/supabase_config.dart

# Add your credentials (see Step 3 above)
```

### Issue: Can't stay logged in

**Solution**: Ensure `AuthWrapper` uses `StreamBuilder` listening to auth state changes

### Issue: Share not working on Android

**Solution**: Add storage permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### Issue: Quotes not loading

**Solution**: 
1. Check Supabase tables are created correctly
2. Verify RLS policies are set
3. Ensure quotes are seeded in database
4. Check console for API errors

### Issue: General build errors

**Solution**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

## 📝 Features Checklist

### ✅ Implemented
- [x] User authentication (signup, login, logout, password reset)
- [x] Browse quotes by category
- [x] Search quotes by keyword/author
- [x] Add/remove favorites with cloud sync
- [x] Quote of the Day
- [x] Share as text
- [x] Share as image (3 templates)
- [x] Dark mode support
- [x] Session persistence
- [x] Pull to refresh
- [x] MVVM architecture

### ⏳ Pending/Future Enhancements
- [ ] Push notifications for daily quote
- [ ] Custom collections management
- [ ] Widget for home screen
- [ ] Additional theme options
- [ ] Font size customization
- [ ] Offline mode with local caching
- [ ] Quote submission by users

## 🔒 Security Notes

**⚠️ IMPORTANT FOR PRODUCTION:**

This setup uses the Supabase **anon public key**, which is safe for client-side apps. However:

1. **Never commit** `supabase_config.dart` to GitHub (already in `.gitignore`)
2. **Row Level Security (RLS)** is enabled to protect user data
3. For production apps, consider using environment variables
4. Rotate keys if accidentally exposed

**What's Protected by RLS:**
- Users can only see/modify their own favorites
- Users can only access their own collections
- All users can read quotes (public data)

## 📄 Dependencies

Key packages used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0      # Backend & Auth
  provider: ^6.1.0               # State management
  share_plus: ^7.2.0             # Share functionality
  path_provider: ^2.1.0          # File system access
  http: ^1.1.0                   # API calls
```

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Provider State Management](https://pub.dev/packages/provider)
- [MVVM in Flutter](https://medium.com/flutter-community/mvvm-in-flutter-edd212fd767a)

## 📄 License

This project is created for educational purposes as part of a mobile development assignment.

## 👨‍💻 Author

**[Your Name]**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for free backend infrastructure
- Quote authors for inspiration
- AI tools (ChatGPT, GitHub Copilot) for accelerating development
- [Your instructor name] for guidance

---

**📌 Note for Evaluators**: This app demonstrates modern Flutter development practices including MVVM architecture, cloud integration, and AI-assisted coding workflows. The configuration file is gitignored for security - please use your own Supabase credentials to test.

**Made with ❤️ using Flutter and AI assistance**
