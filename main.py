import telebot
from telebot.types import ReplyKeyboardMarkup, KeyboardButton
import base64
import os
import re
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
bot = telebot.TeleBot(BOT_TOKEN)

LINK_RE = re.compile(r"^(https?|vless|vmess|ss|trojan)://", re.IGNORECASE)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    markup = ReplyKeyboardMarkup(resize_keyboard=True, row_width=1)
    btn = KeyboardButton('شروع')
    markup.add(btn)
    bot.send_message(message.chat.id, 'ArM\n\nلینک یا Base64 را بفرست.\nمن خودم تشخیص می‌دهم و تبدیل می‌کنم', reply_markup=markup)


@bot.message_handler(func=lambda message: True)
def converter(message):
    text = message.text.strip()
    if LINK_RE.match(text):
        try:
            encoded = base64.b64encode(text.encode("utf-8")).decode("utf-8")
            bot.reply_to(message, encoded)
            bot.send_message(message.chat.id, 'لینک با موفقیت به base64 تبدیل شد ✅')
        except Exception as e:
            bot.reply_to(message, f"❌ خطا:\n{e}")
        return

    try:
        decoded = base64.b64decode(text.encode("utf-8")).decode("utf-8")
        if LINK_RE.match(decoded):
            bot.reply_to(message, decoded)
            bot.send_message(message.chat.id, 'متن Base64 با موفقیت به لینک تبدیل شد ✅')
            return
    except:
        pass
    bot.reply_to(message, "❌ ورودی معتبر نیست\n\nیک لینک با یکی از پروتکل‌های زیر بفرست:\nhttps, http, vless, vmess, ss, trojan\nیا Base64 همین لینک‌ها را ارسال کن.")

bot.infinity_polling()
