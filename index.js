import { NativeModules } from "react-native";

const changeIcon = (iconName) => NativeModules.ChangeIcon.changeIcon(iconName);

const getIcon = () => NativeModules.ChangeIcon.getIcon();

const ChangeIconErrorCode = {
  notSupported: "NOT_SUPPORTED",
  alreadyInUse: "ALREADY_IN_USE",
  systemError: "SYSTEM_ERROR",
}

const checkIcon = (iconName) => NativeModules.ChangeIcon.checkIcon(iconName);

export { changeIcon, ChangeIconErrorCode, getIcon, checkIcon };
