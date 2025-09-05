# 🚀 Google Apps Script Setup Guide

## 🌟 **Step-by-Step Setup Instructions**

You're seeing "No projects" because you need to create a new Apps Script project first. Here's the complete setup process:

---

## 📥 **Step 1: Create New Apps Script Project**

### **Method 1: From Google Slides (Recommended)**
```
1. Open your Google Slides presentation
2. Go to Extensions → Apps Script
3. If you see "No projects", click "New Project"
4. A new Apps Script project will open in a new tab
```

### **Method 2: From Apps Script Website**
```
1. Go to script.google.com
2. Click "New Project"
3. A new Apps Script project will open
4. You'll need to connect it to your Google Slides later
```

---

## 🔧 **Step 2: Set Up the Script**

### **2.1 Clear Default Code**
```
1. In the Apps Script editor, you'll see default code like:
   function myFunction() {
     // Your code here
   }
2. Delete all the default code
3. Copy and paste the entire script from GOOGLE_SLIDES_INTERACTIVE_SCRIPT.js
```

### **2.2 Save the Project**
```
1. Click File → Save (or Ctrl+S)
2. Give your project a name like "Interactive Slides Script"
3. Click "OK"
```

---

## 🎯 **Step 3: Connect to Google Slides**

### **3.1 If you created from Apps Script website:**
```
1. In Apps Script, go to Resources → Libraries
2. Click "Add a library"
3. Enter your Google Slides presentation ID
4. Or use the SlidesApp.getActivePresentation() method
```

### **3.2 If you created from Google Slides:**
```
1. The connection is automatic
2. You can start running functions immediately
```

---

## 🚀 **Step 4: Run the Script**

### **4.1 Select Function**
```
1. In Apps Script, look for the dropdown menu next to "Run"
2. Click the dropdown and select "quickStart"
3. Click the "Run" button (▶️)
```

### **4.2 Grant Permissions**
```
1. When prompted, click "Review permissions"
2. Choose your Google account
3. Click "Advanced" → "Go to [Project Name] (unsafe)"
4. Click "Allow"
```

### **4.3 Check Results**
```
1. Go back to your Google Slides presentation
2. You should see new slides added with interactive elements
3. If not, check the Apps Script logs for errors
```

---

## 🛠️ **Troubleshooting Common Issues**

### **Issue 1: "No projects" in Apps Script**
**Solution:**
```
1. Go to script.google.com
2. Click "New Project"
3. Copy and paste the script
4. Save the project
5. Connect to your Google Slides
```

### **Issue 2: "doGet not found" error**
**Solution:**
```
1. Make sure you select a function from the dropdown
2. Don't just click "Run" without selecting a function
3. Start with "quickStart" function
```

### **Issue 3: Permission denied**
**Solution:**
```
1. Make sure you're logged into the correct Google account
2. Grant all requested permissions
3. Try running the script again
```

### **Issue 4: Script doesn't work**
**Solution:**
```
1. Check the Apps Script logs (View → Logs)
2. Make sure you're in the correct Google Slides presentation
3. Try running individual functions one by one
```

---

## 🎯 **Quick Start Checklist**

- [ ] Open Google Slides presentation
- [ ] Go to Extensions → Apps Script
- [ ] Create new project (if needed)
- [ ] Copy and paste the script
- [ ] Save the project
- [ ] Select "quickStart" from dropdown
- [ ] Click "Run"
- [ ] Grant permissions
- [ ] Check your slides for new interactive elements

---

## 🚀 **Alternative: Direct Setup**

If you're still having issues, try this direct approach:

### **Step 1: Go to Apps Script**
```
1. Open a new tab
2. Go to script.google.com
3. Click "New Project"
```

### **Step 2: Set Up Script**
```
1. Delete default code
2. Paste the entire script
3. Save as "Interactive Slides Script"
```

### **Step 3: Connect to Slides**
```
1. In the script, add this line at the top:
   var presentation = SlidesApp.openById('YOUR_SLIDES_ID');
2. Replace 'YOUR_SLIDES_ID' with your actual presentation ID
3. Save and run
```

### **Step 4: Get Presentation ID**
```
1. Open your Google Slides presentation
2. Look at the URL: https://docs.google.com/presentation/d/SLIDES_ID/edit
3. Copy the SLIDES_ID part
4. Use it in the script
```

---

## 💡 **Pro Tips**

### **1. Start Simple:**
- Begin with just the `quickStart` function
- Test it works before adding more features
- Check your slides after each function

### **2. Use the Logs:**
- Go to View → Logs in Apps Script
- Check for error messages
- Use console.log() statements for debugging

### **3. Test Incrementally:**
- Run one function at a time
- Check results before running the next
- This helps identify which part isn't working

### **4. Backup Your Slides:**
- Make a copy of your presentation before running scripts
- This way you can restore if something goes wrong

---

## 🆘 **Still Having Issues?**

If you're still stuck:

1. **Check your Google account** - Make sure you're logged in
2. **Try a different browser** - Sometimes browser issues cause problems
3. **Clear browser cache** - Old cache can cause issues
4. **Check internet connection** - Apps Script needs internet access
5. **Try incognito mode** - This eliminates extension conflicts

---

## 🎯 **Your Next Steps**

1. **Go to script.google.com**
2. **Click "New Project"**
3. **Copy and paste the script**
4. **Save the project**
5. **Select "quickStart" and run it**
6. **Check your Google Slides for new interactive elements**

This should resolve the "No projects" issue and get your interactive presentation working!
