import { Question, User } from "~/helper/backend";

export type AppState = {
    notifications: Notification[],
    user?: User,
    openQuestions?: Question[],
};

type NotificationLevel = "ok" | "warning" | "error";

type Notification = {
    level: NotificationLevel,
    msg: string,
}

const defaultAppState = {
    notifications: [],
    user: undefined,
    openQuestions: undefined,
};

export const useAppState = (): Ref<AppState> => {
    return useState<AppState>("state", () => defaultAppState);
};

export const addNotification = (app: AppState, level: NotificationLevel, msg: string): void => {
    app.notifications.push({ level, msg })
}
