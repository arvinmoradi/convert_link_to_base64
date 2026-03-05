import telebot
from telebot.types import ReplyKeyboardMarkup, KeyboardButton
import base64
import os
import re
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
bot = telebot.TeleBot(BOT_TOKEN)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    markup = ReplyKeyboardMarkup(resize_keyboard=True)
    markup.row(KeyboardButton('Link ➡️ Base64'))
    markup.row(KeyboardButton('Base64 ➡️ Link'))
    bot.send_message(message.chat.id, 'ArM\n\nتبدیل لینک به base64 و برعکس\n\nیکی از گزینه‌ها را انتخاب کنید:', reply_markup=markup)


@bot.message_handler(func=lambda message: message.text == 'Link ➡️ Base64')
def ask_link(message):
    msg = bot.reply_to(message, "لطفاً لینک را ارسال کنید:")
    bot.register_next_step_handler(msg, convert_link_to_base64)

def convert_link_to_base64(message):
    text = message.text.strip()
    if re.match(r"^(https?|vless|vmess|ss|trojan)://", text):
        try:
            encoded = base64.b64encode(text.encode("utf-8")).decode("utf-8")
            bot.reply_to(message, encoded)
            bot.send_message(message.chat.id, 'لینک با موفقیت به base64 تبدیل شد ✅')
        except Exception as e:
            bot.reply_to(message, f"❌ خطا:\n{e}")
    else:
        bot.reply_to(message, "❌ ساختار اشتباه است")

@bot.message_handler(func=lambda message: message.text == 'Base64 ➡️ Link')
def ask_base64(message):
    msg = bot.reply_to(message, "لطفاً Base64 را ارسال کنید:")
    bot.register_next_step_handler(msg, convert_base64_to_link)

def convert_base64_to_link(message):
    text = message.text.strip()
    try:
        decoded = base64.b64decode(text.encode("utf-8")).decode("utf-8")
        if re.match(r"^(https?|vless|vmess|ss|trojan)://", decoded):
            bot.reply_to(message, decoded)
            bot.send_message(message.chat.id, 'متن base64 با موفقیت به لینک تبدیل شد ✅')
        else:
            bot.reply_to(message, '❌ خروجی Base64 لینک معتبر نیست')
    except Exception as e:
        bot.reply_to(message, f"❌ خطا:\n{e}")

bot.infinity_polling()
