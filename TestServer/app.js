const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const fs = require('fs');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Function to read the database
function readDatabase(callback) {
  fs.readFile(path.join(__dirname, 'db.json'), 'utf8', (err, data) => {
    if (err) {
      console.error("Error reading db.json", err);
      callback(err, null);
    } else {
      const dbData = JSON.parse(data);
      callback(null, dbData);
    }
  });
}

// Function to write to the database
function writeDatabase(dbData, callback) {
  fs.writeFile(path.join(__dirname, 'db.json'), JSON.stringify(dbData, null, 2), 'utf8', (err) => {
    if (err) {
      console.error("Error writing to db.json", err);
      callback(err);
    } else {
      callback(null);
    }
  });
}

io.on('connection', (socket) => {
  console.log('A user connected');

  socket.on('login', (credentials) => {
    readDatabase((err, dbData) => {
      if (err) {
        socket.emit('login_response', {
          success: false, 
          message: 'Server error during login'
        });
        return;
      }
      const user = dbData.users.find(u => u.username === credentials.username && u.password === credentials.password);
      if (user) {
        console.log('User authenticated');
        socket.emit('login_response', {
          success: true, 
          message: 'Login successful', 
          portfolio: dbData.portfolio
        });
      } else {
        console.log('Authentication failed');
        socket.emit('login_response', {
          success: false, 
          message: 'Login failed'
        });
      }
    });
  });

  socket.on('update_profile', (updatedProfile) => {
    readDatabase((err, dbData) => {
      if (err) {
        socket.emit('update_response', { success: false, message: 'Failed to read database for update' });
        return;
      }
      // Assuming updatedProfile structure matches what's expected
      dbData.portfolio = updatedProfile;
      writeDatabase(dbData, (err) => {
        if (err) {
          socket.emit('update_response', { success: false, message: 'Failed to update profile' });
        } else {
          socket.emit('update_response', { success: true, message: 'Profile updated successfully' });
        }
      });
    });
  });

  socket.on('logout', () => {
    console.log('User logged out');
    socket.disconnect(true);
  });

  socket.on('disconnect', (reason) => {
    console.log(`User disconnected due to ${reason}`);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
