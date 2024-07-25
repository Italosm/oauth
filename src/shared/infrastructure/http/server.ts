/* eslint-disable no-console */
import { env } from '../env-config/env';
import { app } from './app';

const port = env.PORT;
const server = app.listen(port, () => {
  console.log(`Server started on port ${port} 💻🖥`);
});
