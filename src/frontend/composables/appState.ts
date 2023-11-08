import { Question, User } from "~/helper/backend";

export type AppState = {
    user?: User,
    openQuestions?: Question[],
};

type NotificationLevel = "ok" | "warning" | "error";


const defaultAppState = {
    user: undefined,
    openQuestions: undefined,
};

export const useAppState = (): Ref<AppState> => {
    return useState<AppState>("state", () => defaultAppState);
};

export const addNotification = (level: NotificationLevel, msg: string): void => {

    if (!process.client) {
        console.error("notification (" + level + "): " + msg);
        return
    }
    const toast = useNuxtApp().$toast;
    switch (level) {
        case "ok": toast.success(msg, { autoClose: 1000 }); break;
        case "warning": toast.warning(msg); break;
        case "error": toast.error(msg); break;
    }
}
