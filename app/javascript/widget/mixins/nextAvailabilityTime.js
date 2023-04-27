import {
  timeSlotParse,
  defaultTimeSlot,
} from 'dashboard/routes/dashboard/settings/inbox/helpers/businessHour.js';
const { utcToZonedTime } = require('date-fns-tz');

export default {
  data() {
    return {
      dayNames: {
        0: 'Sunday',
        1: 'Monday',
        2: 'Tuesday',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday',
      },
      timeSlots: [...defaultTimeSlot],
      timeSlot: {},
    };
  },
  computed: {
    channelConfig() {
      return window.chatwootWebChannel;
    },
    workingHoursEnabled() {
      const { workingHoursEnabled } = this.channelConfig;
      return workingHoursEnabled;
    },
    workingHours() {
      if (this.workingHoursEnabled) {
        return this.channelConfig.workingHours;
      }
      return null;
    },
    timeZoneValue() {
      if (this.workingHoursEnabled) {
        return this.channelConfig.timezone;
      }
      return null;
    },
    currentDayWorkingHours() {
      if (this.workingHoursEnabled) {
        return this.workingHours.find(
          slot => slot.day_of_week === this.currentDay
        );
      }
      return null;
    },
    nextDayWorkingHours() {
      if (this.workingHoursEnabled) {
        let nextDay = this.getNextDay(this.currentDay);
        let nextWorkingHour = this.getNextWorkingHour(nextDay);
        while (!nextWorkingHour) {
          nextDay = this.getNextDay(nextDay);
          nextWorkingHour = this.getNextWorkingHour(nextDay);
        }
        return nextWorkingHour;
      }
      return null;
    },
    newDateWithTimeZone() {
      const date = new Date();
      const timeZone = this.timeZoneValue;
      const zonedDate = utcToZonedTime(date, timeZone);
      return zonedDate;
    },
    presentHour() {
      return this.newDateWithTimeZone.getHours();
    },
    presentMinute() {
      return this.newDateWithTimeZone.getMinutes();
    },
    currentDay() {
      const date = this.newDateWithTimeZone;
      const day = date.getDay();
      const currentDay = Object.keys(this.dayNames).find(
        key => this.dayNames[key] === this.dayNames[day]
      );
      return Number(currentDay);
    },
    currentDayOpenHour() {
      return this.workingHoursEnabled
        ? this.currentDayWorkingHours.open_hour
        : null;
    },
    currentDayOpenMinute() {
      return this.workingHoursEnabled
        ? this.currentDayWorkingHours.open_minutes
        : null;
    },
    currentDayCloseHour() {
      return this.workingHoursEnabled
        ? this.currentDayWorkingHours.close_hour
        : null;
    },
    nextDayOpenHour() {
      if (this.workingHoursEnabled) {
        return this.nextDayWorkingHours.open_all_day
          ? 0
          : this.nextDayWorkingHours.open_hour;
      }
      return null;
    },
    nextDayOpenMinute() {
      return this.workingHoursEnabled
        ? this.nextDayWorkingHours.open_minutes
        : null;
    },
    dayDiff() {
      if (this.workingHoursEnabled) {
        const currentDay = this.currentDay;
        const nextDay = this.nextDayWorkingHours.day_of_week;
        const totalDays = 6;
        return nextDay > currentDay
          ? nextDay - currentDay
          : totalDays - currentDay + nextDay;
      }
      return null;
    },
    dayNameOfNextWorkingDay() {
      if (this.workingHoursEnabled) {
        return this.dayNames[this.nextDayWorkingHours.day_of_week];
      }
      return null;
    },
    hoursAndMinutesBackInOnline() {
      if (this.presentHour >= this.currentDayCloseHour) {
        return this.getHoursAndMinutesUntilNextDayOpen(
          this.nextDayOpenHour,
          this.nextDayOpenMinute,
          this.currentDayCloseHour
        );
      }
      return this.getHoursAndMinutesUntilNextDayOpen(
        this.currentDayOpenHour,
        this.currentDayOpenMinute,
        this.currentDayCloseHour
      );
    },
    exactTimeInAmPm() {
      return `${this.timeSlot.day !== this.currentDay ? 'tomorrow' : ''} ${
        this.timeSlot.day !== this.currentDay ? '' : `at ${this.timeSlot.from}`
      }`;
    },
    hoursLeftValue() {
      const {
        hours: hoursLeft,
        minutes: minutesLeft,
      } = this.hoursAndMinutesBackInOnline;
      const hourString = hoursLeft === 1 ? 'hour' : 'hours';
      const minuteString = minutesLeft === 1 ? 'minute' : 'minutes';
      return `in ${hoursLeft} ${hourString}${
        minutesLeft > 0 ? ` and ${minutesLeft} ${minuteString}` : ''
      }`;
    },
    minutesLeftValue() {
      const { minutes: minutesLeft } = this.hoursAndMinutesBackInOnline;
      const minuteString = minutesLeft === 1 ? 'minute' : 'minutes';
      return `in ${minutesLeft} ${minuteString}`;
    },
    hoursAndMinutesToBack() {
      const {
        hours: hoursLeft,
        minutes: minutesLeft,
      } = this.hoursAndMinutesBackInOnline;
      if (hoursLeft > 3) {
        return this.exactTimeInAmPm;
      }
      if (hoursLeft > 0) {
        return this.hoursLeftValue;
      }
      if (minutesLeft > 0) {
        return this.minutesLeftValue;
      }
      return 'in some time';
    },
    timeLeftToBackInOnline() {
      if (this.dayDiff > 1 && this.presentHour >= this.currentDayCloseHour) {
        return `on ${this.dayNameOfNextWorkingDay}`;
      }
      if (this.hoursAndMinutesBackInOnline.hours >= 24) {
        return `tomorrow`;
      }
      return this.hoursAndMinutesToBack;
    },
  },
  mounted() {
    this.setTimeSlot();
  },
  methods: {
    getNextDay(day) {
      return day === 6 ? 0 : day + 1;
    },
    getNextWorkingHour(day) {
      const workingHour = this.workingHours.find(
        slot => slot.day_of_week === day
      );
      if (workingHour && !workingHour.closed_all_day) {
        return workingHour;
      }
      return null;
    },
    getHoursAndMinutesUntilNextDayOpen(
      openHour,
      openMinutes,
      currentDayCloseHour
    ) {
      const { presentHour, presentMinute } = this;
      if (currentDayCloseHour < openHour) {
        openHour += 24;
      }
      let diffMinutes =
        openHour * 60 + openMinutes - (presentHour * 60 + presentMinute);
      diffMinutes = diffMinutes < 0 ? diffMinutes + 24 * 60 : diffMinutes;
      const [hours, minutes] = [Math.floor(diffMinutes / 60), diffMinutes % 60];
      return { hours, minutes };
    },
    setTimeSlot() {
      if (this.workingHoursEnabled) {
        const timeSlots = this.workingHours;
        const currentSlot =
          this.presentHour >= this.currentDayCloseHour
            ? this.nextDayWorkingHours
            : this.currentDayWorkingHours;
        const slots = timeSlotParse(timeSlots).length
          ? timeSlotParse(timeSlots)
          : defaultTimeSlot;
        this.timeSlots = slots;
        this.timeSlot = this.timeSlots.find(
          slot => slot.day === currentSlot.day_of_week
        );
      }
    },
  },
};
