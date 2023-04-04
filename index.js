require('dotenv/config')

const { Client, IntentsBitField } = require('discord.js')
const { Configuration, OpenAIApi } = require('openai')

let conversationLog = [{ role: 'system', content: "You are a professional developer" }]

function resetConversation() {
  conversationLog = [{ role: 'system', content: "You are a professional developer" }]
}

const client = new Client({
  intents: [
    IntentsBitField.Flags.Guilds,
    IntentsBitField.Flags.GuildMessages,
    IntentsBitField.Flags.MessageContent
  ]
})

const channel = client.channels.cache.get(process.env.CHANNEL_ID)

function resetTimerFunction() {
  resetConversation()
  channel.send('Conversation reset')
  console.log('Conversation reset')
}

let resetTimer = setTimeout(resetTimerFunction, 1000 * 60 * 60 * 2) // 2 hours

client.on('ready', () => {
  console.log(`Logged in as ${client.user.tag}!`)
})

const configuration = new Configuration({
  apiKey: process.env.OPENAI_KEY
})
const openai = new OpenAIApi(configuration)

client.on('messageCreate', async (message) => {
  if (message.author.bot) return
  if (message.channelId !== process.env.CHANNEL_ID) return

  // Reset conversation if user types !reset
  if (message.content.startsWith('!reset')) {
    resetConversation()
    return message.reply('Conversation reset')
  }

  // else add message to conversation log

  conversationLog.push({ role: 'user', content: message.content })

  clearTimeout(resetTimer)

  await message.channel.sendTyping()
  const result = await openai.createChatCompletion({
    model: 'gpt-3.5-turbo',
    messages: conversationLog,
  })

  const msg = result.data.choices[0].message ? result.data.choices[0].message : '`Error: No response from OpenAI`'
  if (msg.length > 2000) return message.reply('`Error: Response too long`')

  message.reply(msg)

  resetTimer = setTimeout(resetTimerFunction, 1000 * 60 * 60 * 2) // 2 hours)

})

client.login(process.env.DISCORD_TOKEN)