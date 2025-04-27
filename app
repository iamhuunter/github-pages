e-room-app v6
CodePreview
import { useState, useEffect, useRef } from 'react'
import { Button } from "/components/ui/button"
import { Input } from "/components/ui/input"
import { Card, CardContent, CardHeader, CardTitle, CardFooter, CardDescription } from "/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "/components/ui/avatar"
import { Label } from "/components/ui/label"
import { Trash, Send, Mic, MicOff, Headphones, Check, Edit, Shield, UserPlus, Upload, Search, Hash, Users, Phone, PhoneOff, Settings } from "lucide-react"

type Role = 'admin' | 'member'
type RoomType = 'text' | 'voice'
type Room = {
  id: string
  name: string
  type: RoomType
  members: number[]
  isLocked?: boolean
  password?: string
}

type User = {
  id: number
  username: string
  password: string
  role: Role
  photo: string
  isVerified: boolean
  currentRoom?: string
  isSpeaking?: boolean
  isMuted?: boolean
  isDeafened?: boolean
}

type Message = {
  id: string
  text: string
  sender: User
  timestamp: Date
  roomId: string
}

// Default data
const defaultPhotos = [
  'https://randomuser.me/api/portraits/men/1.jpg',
  'https://randomuser.me/api/portraits/women/2.jpg',
  'https://randomuser.me/api/portraits/men/3.jpg',
  'https://randomuser.me/api/portraits/women/4.jpg',
  'https://randomuser.me/api/portraits/men/5.jpg',
  'https://randomuser.me/api/portraits/women/6.jpg',
  'https://randomuser.me/api/portraits/men/7.jpg'
]

const mockRooms: Room[] = [
  { id: 'general', name: 'General', type: 'text', members: [1, 2, 3, 4, 5] },
  { id: 'voice-lobby', name: 'Voice Lobby', type: 'voice', members: [2, 4, 6], isLocked: false },
  { id: 'private-chat', name: 'Private Chat', type: 'voice', members: [3, 5], isLocked: true, password: 'secret123' },
  { id: 'gaming', name: 'Gaming', type: 'voice', members: [1, 3, 7], isLocked: false },
  { id: 'help', name: 'Help', type: 'text', members: [1, 6, 7] }
]

const mockUserDatabase: User[] = [
  { id: 1, username: 'admin', password: 'admin123', role: 'admin', photo: defaultPhotos[0], isVerified: true, currentRoom: 'general' },
  { id: 2, username: 'alex', password: 'alex123', role: 'member', photo: defaultPhotos[1], isVerified: true, currentRoom: 'voice-lobby' },
  { id: 3, username: 'taylor', password: 'taylor123', role: 'member', photo: defaultPhotos[2], isVerified: false, currentRoom: 'private-chat' },
  { id: 4, username: 'jordan', password: 'jordan123', role: 'member', photo: defaultPhotos[3], isVerified: true, currentRoom: 'voice-lobby' },
  { id: 5, username: 'casey', password: 'casey123', role: 'member', photo: defaultPhotos[4], isVerified: false, currentRoom: 'private-chat' },
  { id: 6, username: 'riley', password: 'riley123', role: 'member', photo: defaultPhotos[5], isVerified: true, currentRoom: 'voice-lobby' },
  { id: 7, username: 'morgan', password: 'morgan123', role: 'member', photo: defaultPhotos[6], isVerified: false, currentRoom: 'gaming' }
]

export default function VoiceRoomApp() {
  const [currentUser, setCurrentUser] = useState<User | null>(null)
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [message, setMessage] = useState('')
  const [messages, setMessages] = useState<Message[]>([])
  const [users, setUsers] = useState<User[]>(mockUserDatabase)
  const [rooms, setRooms] = useState<Room[]>(mockRooms)
  const [currentRoom, setCurrentRoom] = useState<Room | null>(null)
  const [isVoiceActive, setIsVoiceActive] = useState(false)
  const [isMuted, setIsMuted] = useState(false)
  const [isDeafened, setIsDeafened] = useState(false)
  const [isEditingProfile, setIsEditingProfile] = useState(false)
  const [editUsername, setEditUsername] = useState('')
  const [editPassword, setEditPassword] = useState('')
  const [showAdminPanel, setShowAdminPanel] = useState(false)
  const [newUser, setNewUser] = useState({
    username: '',
    password: '',
    role: 'member' as Role,
    isVerified: false,
    photo: ''
  })
  const [isSignUp, setIsSignUp] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [roomPassword, setRoomPassword] = useState('')
  const [showRoomSettings, setShowRoomSettings] = useState(false)
  const [newRoom, setNewRoom] = useState({
    name: '',
    type: 'voice' as RoomType,
    isLocked: false,
    password: ''
  })
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [previewImage, setPreviewImage] = useState('')

  // Filter rooms based on search query
  const filteredRooms = rooms.filter(room =>
    room.name.toLowerCase().includes(searchQuery.toLowerCase())
  )

  // Get current room members
  const currentRoomMembers = currentRoom 
    ? users.filter(user => user.currentRoom === currentRoom.id)
    : []

  useEffect(() => {
    if (currentUser) {
      setEditUsername(currentUser.username)
      setEditPassword(currentUser.password)
      setPreviewImage(currentUser.photo)
      // Set current room to user's current room or first room
      const userRoom = rooms.find(r => r.id === currentUser.currentRoom) || rooms[0]
      setCurrentRoom(userRoom)
    }
  }, [currentUser])

  useEffect(() => {
    // Simulate voice activity in voice rooms
    if (isVoiceActive && currentRoom?.type === 'voice') {
      const interval = setInterval(() => {
        // Update speaking status for current user
        setUsers(prevUsers => prevUsers.map(user => 
          user.id === currentUser?.id 
            ? { ...user, isSpeaking: !isMuted && !isDeafened } 
            : user
        ))
        
        // Simulate other users speaking randomly
        setUsers(prevUsers => prevUsers.map(user => {
          if (user.id !== currentUser?.id && user.currentRoom === currentRoom?.id) {
            return {
              ...user,
              isSpeaking: Math.random() > 0.7 && !user.isDeafened
            }
          }
          return user
        }))
      }, 2000)
      return () => clearInterval(interval)
    }
  }, [isVoiceActive, isMuted, isDeafened, currentRoom])

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    if (!username.trim() || !password.trim()) return
    
    const foundUser = users.find(user => 
      user.username.toLowerCase() === username.toLowerCase() && 
      user.password === password
    )
    
    if (foundUser) {
      setCurrentUser(foundUser)
    } else {
      alert('Invalid username or password')
    }
  }

  const handleSignUp = (e: React.FormEvent) => {
    e.preventDefault()
    if (!username.trim() || !password.trim()) return
    
    // Check if username already exists
    if (users.some(user => user.username.toLowerCase() === username.toLowerCase())) {
      alert('Username already taken')
      return
    }
    
    const newUser: User = {
      id: Math.max(...users.map(u => u.id)) + 1,
      username,
      password,
      role: 'member',
      photo: previewImage || defaultPhotos[Math.floor(Math.random() * defaultPhotos.length)],
      isVerified: false,
      currentRoom: 'general'
    }
    
    setUsers([...users, newUser])
    setCurrentUser(newUser)
    setPreviewImage('')
  }

  const handleLogout = () => {
    setCurrentUser(null)
    setUsername('')
    setPassword('')
  }

  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault()
    if (!message.trim() || !currentUser || !currentRoom) return
    
    const newMessage: Message = {
      id: Date.now().toString(),
      text: message,
      sender: currentUser,
      timestamp: new Date(),
      roomId: currentRoom.id
    }
    
    setMessages([...messages, newMessage])
    setMessage('')
  }

  const joinRoom = (room: Room) => {
    if (!currentUser) return
    
    // Check if room is locked
    if (room.isLocked) {
      const password = prompt('Enter room password:')
      if (password !== room.password) {
        alert('Incorrect password')
        return
      }
    }
    
    // Leave current room
    if (currentUser.currentRoom) {
      const updatedRooms = rooms.map(r => 
        r.id === currentUser.currentRoom
          ? { ...r, members: r.members.filter(id => id !== currentUser?.id) }
          : r
      )
      setRooms(updatedRooms)
    }
    
    // Join new room
    const updatedRooms = rooms.map(r => 
      r.id === room.id
        ? { ...r, members: [...r.members, currentUser.id] }
        : r
    )
    
    setRooms(updatedRooms)
    setCurrentRoom(room)
    
    // Update user's current room
    const updatedUsers = users.map(user => 
      user.id === currentUser.id
        ? { ...user, currentRoom: room.id }
        : user
    )
    
    setUsers(updatedUsers)
    setCurrentUser(updatedUsers.find(u => u.id === currentUser.id) || null)
    
    // If joining a voice room, activate voice
    if (room.type === 'voice') {
      setIsVoiceActive(true)
      setIsMuted(false)
      setIsDeafened(false)
    } else {
      setIsVoiceActive(false)
    }
  }

  const toggleVoice = () => {
    if (!currentRoom || currentRoom.type !== 'voice') return
    setIsVoiceActive(!isVoiceActive)
    if (!isVoiceActive) {
      setIsMuted(false)
      setIsDeafened(false)
    }
  }

  const toggleMute = () => {
    setIsMuted(!isMuted)
    if (!isMuted) {
      setIsDeafened(false)
    }
  }

  const toggleDeafen = () => {
    setIsDeafened(!isDeafened)
    if (isDeafened) {
      setIsMuted(false)
    } else {
      setIsMuted(true)
    }
  }

  const createRoom = () => {
    if (!newRoom.name.trim()) return
    
    const room: Room = {
      id: newRoom.name.toLowerCase().replace(/\s+/g, '-'),
      name: newRoom.name,
      type: newRoom.type,
      members: currentUser ? [currentUser.id] : [],
      isLocked: newRoom.isLocked,
      password: newRoom.password
    }
    
    setRooms([...rooms, room])
    setNewRoom({
      name: '',
      type: 'voice',
      isLocked: false,
      password: ''
    })
    setShowRoomSettings(false)
    
    // Join the new room
    if (currentUser) {
      joinRoom(room)
    }
  }

  const saveProfileChanges = () => {
    if (!currentUser) return
    
    const updatedUsers = users.map(user => 
      user.id === currentUser.id 
        ? { 
            ...user, 
            username: editUsername, 
            password: editPassword,
            photo: previewImage || user.photo
          }
        : user
    )
    
    setUsers(updatedUsers)
    setCurrentUser({ 
      ...currentUser, 
      username: editUsername, 
      password: editPassword,
      photo: previewImage || currentUser.photo
    })
    setIsEditingProfile(false)
    setPreviewImage('')
  }

  const toggleUserVerification = (userId: number) => {
    if (currentUser?.role !== 'admin') return
    
    const updatedUsers = users.map(user => 
      user.id === userId 
        ? { ...user, isVerified: !user.isVerified }
        : user
    )
    
    setUsers(updatedUsers)
  }

  const deleteUser = (userId: number) => {
    if (currentUser?.role !== 'admin' || userId === currentUser.id) return
    
    setUsers(users.filter(user => user.id !== userId))
    setMessages(messages.filter(msg => msg.sender.id !== userId))
  }

  const addNewUser = () => {
    if (!newUser.username || !newUser.password) return
    
    const newUserObj: User = {
      id: Math.max(...users.map(u => u.id)) + 1,
      username: newUser.username,
      password: newUser.password,
      role: newUser.role,
      photo: newUser.photo || defaultPhotos[Math.floor(Math.random() * defaultPhotos.length)],
      isVerified: newUser.isVerified,
      currentRoom: 'general'
    }
    
    setUsers([...users, newUserObj])
    setNewUser({
      username: '',
      password: '',
      role: 'member',
      isVerified: false,
      photo: ''
    })
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onloadend = () => {
        setPreviewImage(reader.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  const triggerFileInput = () => {
    fileInputRef.current?.click()
  }

  if (!currentUser) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle className="text-2xl">
              {isSignUp ? 'Create Account' : 'Login to Chat'}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={isSignUp ? handleSignUp : handleLogin} className="space-y-4">
              {isSignUp && (
                <div className="flex flex-col items-center">
                  <div className="relative mb-4">
                    <Avatar className="h-20 w-20">
                      <AvatarImage src={previewImage} />
                      <AvatarFallback>
                        {username.charAt(0).toUpperCase() || 'U'}
                      </AvatarFallback>
                    </Avatar>
                    <button
                      type="button"
                      onClick={triggerFileInput}
                      className="absolute -bottom-2 -right-2 bg-primary text-primary-foreground p-2 rounded-full"
                    >
                      <Upload className="h-4 w-4" />
                    </button>
                    <input
                      type="file"
                      ref={fileInputRef}
                      onChange={handleFileChange}
                      accept="image/*"
                      className="hidden"
                    />
                  </div>
                </div>
              )}
              <div>
                <Label htmlFor="username">Username</Label>
                <Input
                  id="username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder="Enter your username"
                  required
                />
              </div>
              <div>
                <Label htmlFor="password">Password</Label>
                <Input
                  id="password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your password"
                  required
                />
              </div>
              <Button type="submit" className="w-full">
                {isSignUp ? 'Sign Up' : 'Login'}
              </Button>
            </form>
          </CardContent>
          <CardFooter className="flex justify-center">
            <button
              onClick={() => setIsSignUp(!isSignUp)}
              className="text-sm text-blue-500 hover:underline flex items-center gap-1"
            >
              {isSignUp ? (
                <>
                  Already have an account? Login
                </>
              ) : (
                <>
                  <UserPlus className="h-4 w-4" />
                  Create new account
                </>
              )}
            </button>
          </CardFooter>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-3 flex justify-between items-center">
          <h1 className="text-xl font-bold">Voice Room App</h1>
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <Avatar>
                <AvatarImage src={currentUser.photo} />
                <AvatarFallback>
                  {currentUser.username.charAt(0).toUpperCase()}
                </AvatarFallback>
              </Avatar>
              <div>
                <div className="flex items-center gap-1">
                  <span className="font-medium">{currentUser.username}</span>
                  {currentUser.isVerified && (
                    <Check className="h-4 w-4 text-black" />
                  )}
                  {currentUser.role === 'admin' && (
                    <Shield className="h-4 w-4 text-yellow-500" />
                  )}
                </div>
                <div className="flex gap-2">
                  <button 
                    onClick={() => setIsEditingProfile(true)}
                    className="text-xs text-blue-500 hover:underline"
                  >
                    Edit Profile
                  </button>
                  {currentUser.role === 'admin' && (
                    <button 
                      onClick={() => setShowAdminPanel(!showAdminPanel)}
                      className="text-xs text-purple-500 hover:underline"
                    >
                      {showAdminPanel ? 'Hide Admin' : 'Show Admin'}
                    </button>
                  )}
                </div>
              </div>
            </div>
            <Button variant="outline" size="sm" onClick={handleLogout}>
              Logout
            </Button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="flex flex-grow container mx-auto px-4 py-6 gap-4">
        {/* Rooms Panel */}
        <Card className="w-64 hidden md:block">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>Channels</CardTitle>
              <div className="flex gap-1">
                {currentUser.role === 'admin' && (
                  <Button 
                    variant="ghost" 
                    size="sm"
                    onClick={() => setShowRoomSettings(true)}
                  >
                    <Hash className="h-4 w-4" />
                  </Button>
                )}
                <Button 
                  variant="ghost" 
                  size="sm"
                  onClick={() => setShowRoomSettings(true)}
                >
                  <Phone className="h-4 w-4" />
                </Button>
              </div>
            </div>
            <div className="relative mt-2">
              <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-gray-500" />
              <Input
                type="search"
                placeholder="Search channels..."
                className="w-full pl-8"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>
          </CardHeader>
          <CardContent className="space-y-2">
            {filteredRooms.map(room => (
              <button
                key={room.id}
                onClick={() => joinRoom(room)}
                className={`w-full flex items-center justify-between p-2 rounded ${currentRoom?.id === room.id ? 'bg-primary text-primary-foreground' : 'hover:bg-gray-100'}`}
              >
                <div className="flex items-center gap-2">
                  {room.type === 'voice' ? (
                    <Headphones className="h-4 w-4" />
                  ) : (
                    <Hash className="h-4 w-4" />
                  )}
                  <span>{room.name}</span>
                  {room.isLocked && (
                    <Shield className="h-3 w-3" />
                  )}
                </div>
                <div className="flex items-center gap-1">
                  <Users className="h-3 w-3" />
                  <span className="text-xs">{room.members.length}</span>
                </div>
              </button>
            ))}
          </CardContent>
        </Card>

        {/* Main Chat Area */}
        <div className="flex-grow flex flex-col gap-4">
          {/* Admin Panel */}
          {showAdminPanel && currentUser.role === 'admin' && (
            <Card>
              <CardHeader>
                <CardTitle>Admin Panel</CardTitle>
                <CardDescription>Manage users and settings</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <h4 className="font-medium mb-2">Add New User</h4>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="newUsername">Username</Label>
                      <Input
                        id="newUsername"
                        value={newUser.username}
                        onChange={(e) => setNewUser({...newUser, username: e.target.value})}
                        placeholder="Username"
                      />
                    </div>
                    <div>
                      <Label htmlFor="newPassword">Password</Label>
                      <Input
                        id="newPassword"
                        type="password"
                        value={newUser.password}
                        onChange={(e) => setNewUser({...newUser, password: e.target.value})}
                        placeholder="Password"
                      />
                    </div>
                  </div>
                  <div className="mt-2 flex items-center gap-4">
                    <div className="flex items-center gap-2">
                      <Label htmlFor="newUserPhoto">Photo:</Label>
                      <button
                        type="button"
                        onClick={() => fileInputRef.current?.click()}
                        className="flex items-center gap-1 text-sm"
                      >
                        <Upload className="h-4 w-4" />
                        Upload
                      </button>
                      <input
                        type="file"
                        ref={fileInputRef}
                        onChange={(e) => {
                          const file = e.target.files?.[0]
                          if (file) {
                            const reader = new FileReader()
                            reader.onloadend = () => {
                              setNewUser({...newUser, photo: reader.result as string})
                            }
                            reader.readAsDataURL(file)
                          }
                        }}
                        accept="image/*"
                        className="hidden"
                      />
                      {newUser.photo && (
                        <Avatar className="h-8 w-8">
                          <AvatarImage src={newUser.photo} />
                          <AvatarFallback>U</AvatarFallback>
                        </Avatar>
                      )}
                    </div>
                  </div>
                  <div className="flex items-center gap-4 mt-2">
                    <div className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        id="newUserAdmin"
                        checked={newUser.role === 'admin'}
                        onChange={(e) => setNewUser({...newUser, role: e.target.checked ? 'admin' : 'member'})}
                        className="h-4 w-4"
                      />
                      <Label htmlFor="newUserAdmin">Admin Role</Label>
                    </div>
                    <div className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        id="newUserVerified"
                        checked={newUser.isVerified}
                        onChange={(e) => setNewUser({...newUser, isVerified: e.target.checked})}
                        className="h-4 w-4"
                      />
                      <Label htmlFor="newUserVerified">Verified</Label>
                    </div>
                    <Button onClick={addNewUser} size="sm">
                      Add User
                    </Button>
                  </div>
                </div>

                <div>
                  <h4 className="font-medium mb-2">Manage Users</h4>
                  <div className="space-y-2">
                    {users.map(user => (
                      <div key={user.id} className="flex items-center justify-between p-2 border rounded">
                        <div className="flex items-center gap-2">
                          <Avatar className="h-8 w-8">
                            <AvatarImage src={user.photo} />
                            <AvatarFallback>
                              {user.username.charAt(0).toUpperCase()}
                            </AvatarFallback>
                          </Avatar>
                          <div>
                            <div className="flex items-center gap-1">
                              <span>{user.username}</span>
                              {user.isVerified && (
                                <Check className="h-3 w-3 text-black" />
                              )}
                              {user.role === 'admin' && (
                                <Shield className="h-3 w-3 text-yellow-500" />
                              )}
                            </div>
                            <div className="text-xs text-gray-500">
                              ID: {user.id} | Room: {user.currentRoom}
                            </div>
                          </div>
                        </div>
                        <div className="flex gap-2">
                          <Button
                            variant={user.isVerified ? 'default' : 'outline'}
                            size="sm"
                            onClick={() => toggleUserVerification(user.id)}
                          >
                            {user.isVerified ? 'Verified' : 'Verify'}
                          </Button>
                          {user.id !== currentUser.id && (
                            <Button
                              variant="destructive"
                              size="sm"
                              onClick={() => deleteUser(user.id)}
                            >
                              Delete
                            </Button>
                          )}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Room Settings Modal */}
          {showRoomSettings && (
            <Card>
              <CardHeader>
                <CardTitle>Create New Room</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="roomName">Room Name</Label>
                  <Input
                    id="roomName"
                    value={newRoom.name}
                    onChange={(e) => setNewRoom({...newRoom, name: e.target.value})}
                    placeholder="Enter room name"
                  />
                </div>
                <div>
                  <Label>Room Type</Label>
                  <div className="flex gap-4 mt-2">
                    <label className="flex items-center space-x-2">
                      <input
                        type="radio"
                        checked={newRoom.type === 'voice'}
                        onChange={() => setNewRoom({...newRoom, type: 'voice'})}
                        className="h-4 w-4"
                      />
                      <span>Voice Room</span>
                    </label>
                    <label className="flex items-center space-x-2">
                      <input
                        type="radio"
                        checked={newRoom.type === 'text'}
                        onChange={() => setNewRoom({...newRoom, type: 'text'})}
                        className="h-4 w-4"
                      />
                      <span>Text Channel</span>
                    </label>
                  </div>
                </div>
                <div>
                  <div className="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      id="roomLocked"
                      checked={newRoom.isLocked}
                      onChange={(e) => setNewRoom({...newRoom, isLocked: e.target.checked})}
                      className="h-4 w-4"
                    />
                    <Label htmlFor="roomLocked">Lock Room</Label>
                  </div>
                  {newRoom.isLocked && (
                    <div className="mt-2">
                      <Label htmlFor="roomPassword">Password</Label>
                      <Input
                        id="roomPassword"
                        type="password"
                        value={newRoom.password}
                        onChange={(e) => setNewRoom({...newRoom, password: e.target.value})}
                        placeholder="Set room password"
                      />
                    </div>
                  )}
                </div>
              </CardContent>
              <CardFooter className="flex justify-end gap-2">
                <Button variant="outline" onClick={() => setShowRoomSettings(false)}>
                  Cancel
                </Button>
                <Button onClick={createRoom}>
                  Create Room
                </Button>
              </CardFooter>
            </Card>
          )}

          {/* Edit Profile Modal */}
          {isEditingProfile && (
            <Card>
              <CardHeader>
                <CardTitle>Edit Profile</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex flex-col items-center">
                  <div className="relative mb-4">
                    <Avatar className="h-20 w-20">
                      <AvatarImage src={previewImage || currentUser.photo} />
                      <AvatarFallback>
                        {editUsername.charAt(0).toUpperCase() || 'U'}
                      </AvatarFallback>
                    </Avatar>
                    <button
                      type="button"
                      onClick={triggerFileInput}
                      className="absolute -bottom-2 -right-2 bg-primary text-primary-foreground p-2 rounded-full"
                    >
                      <Upload className="h-4 w-4" />
                    </button>
                    <input
                      type="file"
                      ref={fileInputRef}
                      onChange={handleFileChange}
                      accept="image/*"
                      className="hidden"
                    />
                  </div>
                </div>
                <div>
                  <Label htmlFor="editUsername">Username</Label>
                  <Input
                    id="editUsername"
                    value={editUsername}
                    onChange={(e) => setEditUsername(e.target.value)}
                  />
                </div>
                <div>
                  <Label htmlFor="editPassword">Password</Label>
                  <Input
                    id="editPassword"
                    type="password"
                    value={editPassword}
                    onChange={(e) => setEditPassword(e.target.value)}
                  />
                </div>
                {currentUser.role === 'admin' && (
                  <div className="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      id="editVerified"
                      checked={currentUser.isVerified}
                      onChange={() => toggleUserVerification(currentUser.id)}
                      className="h-4 w-4"
                    />
                    <Label htmlFor="editVerified">Verified Profile</Label>
                  </div>
                )}
              </CardContent>
              <CardFooter className="flex justify-end gap-2">
                <Button variant="outline" onClick={() => {
                  setIsEditingProfile(false)
                  setPreviewImage('')
                }}>
                  Cancel
                </Button>
                <Button onClick={saveProfileChanges}>
                  Save Changes
                </Button>
              </CardFooter>
            </Card>
          )}

          {/* Chat Area */}
          {currentRoom && (
            <Card className="flex-grow flex flex-col">
              <CardHeader className="border-b">
                <div className="flex items-center justify-between">
                  <CardTitle>
                    {currentRoom.type === 'voice' ? (
                      <div className="flex items-center gap-2">
                        <Headphones className="h-5 w-5" />
                        {currentRoom.name}
                        {currentRoom.isLocked && (
                          <Shield className="h-4 w-4" />
                        )}
                      </div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <Hash className="h-5 w-5" />
                        {currentRoom.name}
                      </div>
                    )}
                  </CardTitle>
                  {currentRoom.type === 'voice' && (
                    <div className="flex gap-2">
                      <Button
                        variant={isVoiceActive ? 'default' : 'outline'}
                        size="sm"
                        onClick={toggleVoice}
                      >
                        {isVoiceActive ? (
                          <Mic className="h-4 w-4" />
                        ) : (
                          <MicOff className="h-4 w-4" />
                        )}
                      </Button>
                      <Button
                        variant={isMuted ? 'destructive' : 'outline'}
                        size="sm"
                        onClick={toggleMute}
                        disabled={!isVoiceActive}
                      >
                        <MicOff className="h-4 w-4" />
                      </Button>
                      <Button
                        variant={isDeafened ? 'destructive' : 'outline'}
                        size="sm"
                        onClick={toggleDeafen}
                        disabled={!isVoiceActive}
                      >
                        <Headphones className="h-4 w-4" />
                      </Button>
                    </div>
                  )}
                </div>
                <div className="flex items-center gap-2">
                  <Users className="h-4 w-4" />
                  <span className="text-sm">
                    {currentRoomMembers.length} member{currentRoomMembers.length !== 1 ? 's' : ''}
                  </span>
                </div>
              </CardHeader>

              {currentRoom.type === 'text' ? (
                <>
                  <CardContent className="flex-grow p-4 overflow-y-auto space-y-4">
                    {messages
                      .filter(msg => msg.roomId === currentRoom.id)
                      .length === 0 ? (
                      <p className="text-center text-gray-500">No messages yet. Be the first to send one!</p>
                    ) : (
                      messages
                        .filter(msg => msg.roomId === currentRoom.id)
                        .map((msg) => (
                          <div key={msg.id} className="group relative">
                            <div className={`p-3 rounded-lg ${msg.sender.id === currentUser.id ? 'bg-primary text-primary-foreground ml-auto max-w-xs' : 'bg-gray-100 mr-auto max-w-xs'}`}>
                              <div className="flex items-center gap-2">
                                <Avatar className="h-6 w-6">
                                  <AvatarImage src={msg.sender.photo} />
                                  <AvatarFallback>
                                    {msg.sender.username.charAt(0).toUpperCase()}
                                  </AvatarFallback>
                                </Avatar>
                                <div className="flex-1">
                                  <div className="flex items-center gap-1">
                                    <span className="font-bold">{msg.sender.username}</span>
                                    {msg.sender.isVerified && (
                                      <Check className="h-3 w-3 text-black" />
                                    )}
                                    {msg.sender.role === 'admin' && (
                                      <Shield className="h-3 w-3 text-yellow-500" />
                                    )}
                                  </div>
                                  <div className="text-xs opacity-80">
                                    {msg.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                  </div>
                                </div>
                              </div>
                              <div className="mt-2">{msg.text}</div>
                            </div>
                            {currentUser.role === 'admin' && (
                              <button
                                onClick={() => handleDeleteMessage(msg.id)}
                                className="absolute -top-2 -right-2 bg-destructive text-destructive-foreground p-1 rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                              >
                                <Trash className="h-3 w-3" />
                              </button>
                            )}
                          </div>
                        ))
                    )}
                  </CardContent>
                  <CardFooter className="border-t">
                    <form onSubmit={handleSendMessage} className="w-full flex gap-2">
                      <Input
                        value={message}
                        onChange={(e) => setMessage(e.target.value)}
                        placeholder="Type your message..."
                        className="flex-grow"
                      />
                      <Button type="submit" size="icon">
                        <Send className="h-4 w-4" />
                      </Button>
                    </form>
                  </CardFooter>
                </>
              ) : (
                <CardContent className="flex-grow p-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {currentRoomMembers.map(user => (
                      <div 
                        key={user.id} 
                        className={`flex flex-col items-center p-4 border rounded-lg ${user.isSpeaking ? 'border-green-500 bg-green-50' : ''}`}
                      >
                        <div className="relative mb-2">
                          <Avatar className="h-16 w-16">
                            <AvatarImage src={user.photo} />
                            <AvatarFallback>
                              {user.username.charAt(0).toUpperCase()}
                            </AvatarFallback>
                          </Avatar>
                          {user.isSpeaking && (
                            <div className="absolute -bottom-1 -right-1 bg-green-500 rounded-full p-1.5">
                              <Mic className="h-3 w-3 text-white" />
                            </div>
                          )}
                          {user.isMuted && (
                            <div className="absolute -bottom-1 -right-1 bg-red-500 rounded-full p-1.5">
                              <MicOff className="h-3 w-3 text-white" />
                            </div>
                          )}
                        </div>
                        <div className="flex items-center gap-1">
                          <span className="font-medium">{user.username}</span>
                          {user.isVerified && (
                            <Check className="h-3 w-3 text-black" />
                          )}
                          {user.role === 'admin' && (
                            <Shield className="h-3 w-3 text-yellow-500" />
                          )}
                        </div>
                        <div className="text-sm text-gray-500">
                          {user.id === currentUser.id ? 'You' : 'Member'}
                        </div>
                        {user.isDeafened && (
                          <div className="text-xs text-red-500 mt-1 flex items-center gap-1">
                            <Headphones className="h-3 w-3" />
                            <span>Deafened</span>
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </CardContent>
              )}
            </Card>
          )}
        </div>
      </div>
    </div>
  )
}
