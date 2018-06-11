import React, { Component } from 'react';

import { Platform, StyleSheet, Text, View, TouchableOpacity } from 'react-native';

import HUD from 'react-native-hud-hybrid';

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' + 'Shake or press menu button for dev menu',
});

export default class App extends Component {
  constructor(props) {
    super(props);
    this.push = this.push.bind(this);
    this.loading = this.loading.bind(this);
  }

  componentDidMount() {
    HUD.config({
      backgroundColor: '#BB000000',
      tintColor: '#FFFFFF',
      // cornerRadius: 5, // only for android
      // duration: 2000,
      // graceTime: 3000,
      // minShowTime: 800,
      // dimAmount: 0.0, // only for andriod
      loadingText: '加载中...',
    });
    this.props.navigation.isRoot().then(isRoot => {
      if (!isRoot) {
        setTimeout(() => {
          this.props.navigation.pop();
        }, 2000);
      }
    });
  }

  componentWillUnmount() {
    if (this.hud) {
      console.info('will unmount ----------');
      this.hud.hideLoading();
    }
  }

  loading() {
    this.hud = HUD.showLoading();
    setTimeout(() => {
      this.hud.hideLoading();
      HUD.done('任务已经完成啦！');
    }, 5000);
  }

  text() {
    HUD.text('Hello World!!');
  }

  info() {
    HUD.info('有条消息要告诉你');
  }

  done() {
    HUD.done('任务已经完成啦！');
  }

  error() {
    HUD.error('可能什么地方出错了！');
  }

  push() {
    this.props.navigation.push('playground');
  }

  render() {
    return (
      <View style={styles.container}>
        <TouchableOpacity onPress={this.loading} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> loading </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.text} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> text </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.info} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> info </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.done} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> done </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.error} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> error </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={this.push} activeOpacity={0.2} style={styles.button}>
          <Text style={styles.buttonText}> push and auto pop back </Text>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'flex-start',
    alignItems: 'stretch',
    backgroundColor: '#F5FCFF',
    paddingTop: 16 + 88,
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  button: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 40,
  },

  buttonText: {
    backgroundColor: 'transparent',
    color: 'rgb(34,88,220)',
  },
});
