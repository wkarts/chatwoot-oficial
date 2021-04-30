import { action } from '@storybook/addon-actions';
import AddNote from '../../app/javascript/dashboard/routes/dashboard/contacts/components/AddNote';

export default {
  title: 'Components/Notes/Add',
  component: AddNote,
  argTypes: {},
};

const Template = (args, { argTypes }) => ({
  props: Object.keys(argTypes),
  components: { AddNote },
  template: '<add-note v-bind="$props" @add="onAdd"></-note>',
});

export const Add = Template.bind({});
Add.args = {
  onAdd: action('Added'),
};
