
export default function (kibana) {
  return new kibana.Plugin({
   uiExports: {
     app: {
        title: 'gradiant_style',
        order: -100,
        description: 'Gradiant Styling',
        main: 'plugins/gradiant_style/index.js',
        hidden: true
     }
    }
  });
};
