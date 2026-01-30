import telebot
from telebot.types import ReplyKeyboardMarkup, KeyboardButton
import base64
import os
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("BOT_TOKEN")
bot = telebot.TeleBot(BOT_TOKEN)

@bot.message_handler(commands=['start'])
def send_welcome(message):
    markup = ReplyKeyboardMarkup(resize_keyboard=True, row_width=1)
    btn = KeyboardButton('شروع')
    markup.add(btn)
    bot.send_message(message.chat.id, '🍃 ArM 🍃\n\nربات تبدیل لینک به base64\n\nلینک را برای تبدیل به base64 ارسال کنید', reply_markup=markup)

@bot.message_handler(func=lambda message: message.text == 'شروع')
def handle_start(message):
    send_welcome(message)


@bot.message_handler(func=lambda message: True)
def convert_link_to_base64(message):
    text = message.text.strip()

    try:
        encoded = base64.b64encode(text.encode("utf-8")).decode("utf-8")
        bot.send_message(message.chat.id, encoded)
        bot.send_message(message.chat.id, 'لینک با موفقیت به base64 تبدیل شد ✅')
    except Exception as e:
        bot.reply_to(message, f"❌ خطا:\n{e}")

bot.infinity_polling()
